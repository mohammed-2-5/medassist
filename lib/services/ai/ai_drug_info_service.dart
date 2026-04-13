import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_assist/services/ai/ai_prompt_sanitizer.dart';
import 'package:med_assist/services/ai/gemini_service.dart';
import 'package:med_assist/services/ai/groq_service.dart';

class DrugInfoResult {
  const DrugInfoResult({
    this.genericName,
    this.activeIngredients,
    this.drugCategory,
    this.purpose,
    this.commonSideEffects,
    this.warnings,
    this.route,
  });

  factory DrugInfoResult.fromJson(Map<String, dynamic> json) {
    return DrugInfoResult(
      genericName: json['genericName'] as String?,
      activeIngredients: _parseList(json['activeIngredients']),
      drugCategory: json['category'] as String?,
      purpose: json['purpose'] as String?,
      commonSideEffects: _parseList(json['commonSideEffects']),
      warnings: _parseList(json['warnings']),
      route: json['route'] as String?,
    );
  }

  final String? genericName;
  final List<String>? activeIngredients;
  final String? drugCategory;
  final String? purpose;
  final List<String>? commonSideEffects;
  final List<String>? warnings;
  final String? route;

  bool get isEmpty =>
      genericName == null &&
      activeIngredients == null &&
      drugCategory == null &&
      purpose == null;

  static List<String>? _parseList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return [value];
    return null;
  }
}

class AiInteractionResult {
  const AiInteractionResult({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  factory AiInteractionResult.fromJson(Map<String, dynamic> json) {
    return AiInteractionResult(
      drug1: json['drug1'] as String? ?? '',
      drug2: json['drug2'] as String? ?? '',
      severity: json['severity'] as String? ?? 'moderate',
      description: json['description'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  final String drug1;
  final String drug2;
  final String severity;
  final String description;
  final String recommendation;
}

class AiDrugInfoService {
  factory AiDrugInfoService() => _instance;
  AiDrugInfoService._internal();
  static final AiDrugInfoService _instance = AiDrugInfoService._internal();

  final GroqService _groqService = GroqService();
  final GeminiService _geminiService = GeminiService();

  Future<DrugInfoResult?> fetchDrugInfo(String drugName) async {
    final sanitized = AiPromptSanitizer.sanitizeUserMessage(drugName);
    if (sanitized.isEmpty) return null;

    final prompt = '''Return ONLY valid JSON, no markdown, no explanation.
For the drug "$sanitized", return:
{
  "genericName": "generic name or null",
  "activeIngredients": ["ingredient1", "ingredient2"],
  "category": "drug class e.g. NSAID, antibiotic, antihypertensive",
  "purpose": "what it treats in 5-10 words",
  "commonSideEffects": ["side effect 1", "side effect 2", "side effect 3"],
  "warnings": ["warning 1", "warning 2"],
  "route": "oral or topical or injection or inhalation"
}
If you don't know this drug, return: {"unknown": true}''';

    try {
      final response = await _tryGetResponse(prompt);
      if (response == null) return null;

      final json = _extractJson(response);
      if (json == null || json.containsKey('unknown')) return null;

      return DrugInfoResult.fromJson(json);
    } catch (e) {
      debugPrint('AiDrugInfoService: fetchDrugInfo failed: $e');
      return null;
    }
  }

  Future<List<AiInteractionResult>> checkInteractions({
    required String newDrug,
    required List<String> existingDrugs,
    required Map<String, String> drugIngredients,
  }) async {
    if (existingDrugs.isEmpty) return [];

    final drugList = existingDrugs.map((name) {
      final ingredients = drugIngredients[name];
      return ingredients != null ? '$name ($ingredients)' : name;
    }).join(', ');

    final newIngredients = drugIngredients[newDrug];
    final newDrugDesc =
        newIngredients != null ? '$newDrug ($newIngredients)' : newDrug;

    final prompt = '''Return ONLY valid JSON array, no markdown, no explanation.
Check drug interactions between NEW drug: $newDrugDesc
and EXISTING drugs: $drugList

Return array of interactions found (empty array if none):
[{"drug1": "name1", "drug2": "name2", "severity": "minor|moderate|major|severe", "description": "what happens", "recommendation": "what to do"}]''';

    try {
      final response = await _tryGetResponse(prompt);
      if (response == null) return [];

      final jsonStr = _extractJsonArray(response);
      if (jsonStr == null) return [];

      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => AiInteractionResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('AiDrugInfoService: checkInteractions failed: $e');
      return [];
    }
  }

  Future<String?> _tryGetResponse(String prompt) async {
    try {
      _groqService.initialize();
      return await _sendRawGroq(prompt);
    } catch (_) {
      try {
        _geminiService.initialize();
        return await _geminiService.sendMessage(prompt);
      } catch (_) {
        return null;
      }
    }
  }

  Future<String> _sendRawGroq(String prompt) async {
    return _groqService.sendRawCompletion(prompt);
  }

  Map<String, dynamic>? _extractJson(String response) {
    try {
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) return null;
      return jsonDecode(response.substring(start, end + 1))
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? _extractJsonArray(String response) {
    try {
      final start = response.indexOf('[');
      final end = response.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) return null;
      return response.substring(start, end + 1);
    } catch (_) {
      return null;
    }
  }
}
