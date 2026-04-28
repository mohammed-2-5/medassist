import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/core/constants/api_constants.dart';
import 'package:med_assist/services/ai/ai_prompt_sanitizer.dart';

/// Groq API Service - Ultra-fast LLM inference
/// Uses Llama 3 8B model for medical assistance
///
/// Free Tier: 14,400 requests/day (10× better than Gemini!)
/// Speed: Sub-1 second responses
/// Model: llama3-8b-8192 (excellent for medical queries)
class GroqService {
  factory GroqService() => _instance;

  GroqService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.groqBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.groqApiKey}',
        },
      ),
    );
  }
  static final GroqService _instance = GroqService._internal();

  late final Dio _dio;
  final List<Map<String, String>> _chatHistory = [];
  bool _initialized = false;

  /// Initialize Groq service with system prompt
  void initialize() {
    if (_initialized) return;

    _chatHistory.clear();
    _chatHistory.add({
      'role': 'system',
      'content': _getSystemPrompt(),
    });

    _initialized = true;
    debugPrint(
      'Groq AI service initialized with model: ${ApiConstants.groqModel}',
    );
  }

  /// Get system prompt for medical assistant
  String _getSystemPrompt() {
    return '''
You are MedAssist, a personal medication assistant built into a medication reminder app.

You have access to the user's actual medication list, adherence history, and stock levels — use this context to give personalized, specific answers whenever relevant.

RULES:
1. Respond in the SAME language the user writes in — Arabic or English, never mix them. When the user writes Arabic, reply in everyday Egyptian colloquial (عامية مصرية) — not formal Modern Standard Arabic.
2. NEVER diagnose, prescribe, or recommend changing a prescribed dose.
3. If you are not sure about a fact, say so plainly ("مش متأكد، الأفضل تسأل الدكتور" / "I'm not certain — please ask your doctor or pharmacist"). Do NOT guess or invent drug names, doses, or interactions.
4. For drug questions: give purpose, key side effects, and one practical tip.
5. For missed dose questions: use the user's specific drug context if available, not generic advice.
6. Emergency signals → tell the user to call emergency services or go to the ER immediately, before any other advice. Emergencies include: chest pain, difficulty breathing, severe allergic reaction (face/throat swelling), uncontrolled bleeding, sudden severe headache, and any FAST stroke sign — Face drooping, Arm weakness, Speech slurred.
7. Always remind the user to consult their doctor or pharmacist for personal medical decisions, but in a calm tone — do not over-alarm.
8. Use bullet points for lists. Keep answers under 120 words unless the user asks for more detail. Plain language only — no medical jargon.
9. If the user's medication list is empty, briefly explain that they can add their medications from the Home tab using the "+" button so you can give personalized advice.''';
  }

  /// Send message and get AI response
  Future<String> sendMessage(
    String message, {
    String? medicationContext,
  }) async {
    try {
      if (!_initialized) {
        initialize();
      }

      final userMessage = AiPromptSanitizer.sanitizeUserMessage(message);
      if (userMessage.isEmpty) {
        return 'Please enter a message.';
      }

      debugPrint('Sending message to Groq: $userMessage');

      // If medication context provided, inject it into system prompt
      if (medicationContext != null && medicationContext.isNotEmpty) {
        _updateSystemPromptWithContext(
          AiPromptSanitizer.sanitizeContext(medicationContext),
        );
      }

      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      final responseText = await _tryCompletion(
        model: ApiConstants.groqModel,
        messages: _chatHistory,
        maxTokens: 800,
      );

      // Add AI response to history
      _chatHistory.add({
        'role': 'assistant',
        'content': responseText,
      });

      // Limit history to last 10 messages (prevent context overflow)
      if (_chatHistory.length > 21) {
        final systemPrompt = _chatHistory.first;
        final recentMessages = _chatHistory
            .skip(_chatHistory.length - 20)
            .toList();
        _chatHistory.clear();
        _chatHistory.add(systemPrompt);
        _chatHistory.addAll(recentMessages);
      }

      debugPrint(
        'Received response from Groq: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...',
      );

      return responseText;
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      debugPrint('Groq API Error: $errorMsg');

      if (_chatHistory.isNotEmpty && _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }

      throw GroqException(errorMsg);
    } catch (e) {
      debugPrint('Error sending message to Groq: $e');

      if (_chatHistory.isNotEmpty && _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }

      throw GroqException('An unexpected error occurred. Please try again.');
    }
  }

  /// Try primary model, fall back to groqFallbackModel on failure.
  Future<String> _tryCompletion({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    Future<String> call(String m) async {
      debugPrint('Groq: trying model $m');
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': m,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'top_p': 1,
          'stream': false,
        },
      );
      final choices = response.data?['choices'] as List?;
      if (choices == null || choices.isEmpty) throw Exception('No response');
      final msg =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>?;
      final raw = msg?['content']?.toString().trim() ?? '';
      if (raw.isEmpty) throw Exception('Empty response');
      return _stripThinkTags(raw);
    }

    try {
      return await call(model);
    } on Object catch (e) {
      if (model == ApiConstants.groqFallbackModel) rethrow;
      debugPrint('Groq: primary model failed ($e), retrying with fallback');
      return call(ApiConstants.groqFallbackModel);
    }
  }

  // Strips reasoning blocks that Qwen3 prepends before its answer.
  // Handles both well-formed <think>…</think> and truncated <think>… with no
  // closing tag (which happens when max_tokens cuts the response mid-thought).
  String _stripThinkTags(String text) {
    var stripped = text.replaceAll(
      RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false),
      '',
    );
    final openOnly = RegExp(r'<think>', caseSensitive: false).firstMatch(stripped);
    if (openOnly != null) {
      stripped = stripped.substring(0, openOnly.start);
    }
    return stripped.trim();
  }

  /// Update system prompt with medication context
  void _updateSystemPromptWithContext(String medicationContext) {
    if (_chatHistory.isEmpty) return;

    // Update system prompt with context
    _chatHistory[0] = {
      'role': 'system',
      'content':
          '''${_getSystemPrompt()}

CURRENT USER CONTEXT:
$medicationContext

IMPORTANT: Use this context to provide personalized advice. Reference their specific medications when relevant.''',
    };
  }

  /// Parse error message from DioException
  String _parseErrorMessage(DioException e) {
    final errorData = e.response?.data;

    if (errorData is Map) {
      final error = errorData['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
    }

    final statusCode = e.response?.statusCode;

    if (statusCode == 401) {
      return 'Invalid API key. Please check configuration.';
    } else if (statusCode == 429) {
      return 'Rate limit exceeded. Please try again in a moment.';
    } else if (statusCode == 500 || statusCode == 503) {
      return 'Groq service is temporarily unavailable. Trying backup...';
    } else if (statusCode != null) {
      return 'API error ($statusCode). Please try again.';
    }

    return e.message ?? 'Network error. Please check your connection.';
  }

  Future<String> sendRawCompletion(String prompt) async {
    if (!_initialized) initialize();

    return _tryCompletion(
      model: ApiConstants.groqModel,
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      temperature: 0.3,
      maxTokens: 3000,
    );
  }

  /// Clear chat history and start fresh
  void clearHistory() {
    _chatHistory.clear();
    _initialized = false;
    initialize();
    debugPrint('Groq chat history cleared');
  }

  /// Get suggested prompts for common questions
  List<String> getSuggestedPrompts() {
    return [
      'What are common side effects of blood pressure medications?',
      'How should I store my medications?',
      'What should I do if I miss a dose?',
      'Tell me about drug interactions',
      'Tips for remembering to take medications',
      'When should I take medication with food?',
      'How can I manage medication side effects?',
      'What are signs I should contact my doctor?',
    ];
  }

  /// Check if service is available (for testing)
  Future<bool> isAvailable() async {
    try {
      final testResponse = await _dio.get('/models');
      return testResponse.statusCode == 200;
    } catch (e) {
      debugPrint('Groq availability check failed: $e');
      return false;
    }
  }

  /// Get current chat history length
  int get historyLength => _chatHistory.length;

  /// Dispose resources
  void dispose() {
    _chatHistory.clear();
    _initialized = false;
    debugPrint('Groq service disposed');
  }
}

/// Custom exception for Groq API errors
class GroqException implements Exception {
  GroqException(this.message);
  final String message;

  @override
  String toString() => message;
}
