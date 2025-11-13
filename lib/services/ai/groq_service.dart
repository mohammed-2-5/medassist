import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/core/constants/api_constants.dart';

/// Groq API Service - Ultra-fast LLM inference
/// Uses Llama 3 8B model for medical assistance
///
/// Free Tier: 14,400 requests/day (10× better than Gemini!)
/// Speed: Sub-1 second responses
/// Model: llama3-8b-8192 (excellent for medical queries)
class GroqService {
  factory GroqService() => _instance;

  GroqService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.groqBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.groqApiKey}',
      },
    ));
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
    debugPrint('Groq AI service initialized with model: ${ApiConstants.groqModel}');
  }

  /// Get system prompt for medical assistant
  String _getSystemPrompt() {
    return '''
You are a helpful medical assistant AI for MedAssist, a medication reminder app.

Your role is to provide accurate, helpful information about medications and health.

IMPORTANT GUIDELINES:
1. Always prioritize safety - remind users to consult healthcare professionals
2. Provide clear, concise, easy-to-understand information
3. Be empathetic and supportive
4. NEVER diagnose conditions or prescribe medications
5. Focus on:
   - Medication information (uses, side effects, interactions)
   - General health tips
   - Medication adherence advice
   - When to seek professional help

Keep responses concise (2-3 paragraphs unless asked for detail).
Use bullet points for lists.
Always end with a helpful follow-up question when appropriate.''';
  }

  /// Send message and get AI response
  Future<String> sendMessage(String message, {String? medicationContext}) async {
    try {
      if (!_initialized) {
        initialize();
      }

      final userMessage = message.trim();
      if (userMessage.isEmpty) {
        return 'Please enter a message.';
      }

      debugPrint('Sending message to Groq: $userMessage');

      // If medication context provided, inject it into system prompt
      if (medicationContext != null && medicationContext.isNotEmpty) {
        _updateSystemPromptWithContext(medicationContext);
      }

      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // Prepare API request (OpenAI-compatible format)
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': ApiConstants.groqModel,
          'messages': _chatHistory,
          'temperature': 0.7,
          'max_tokens': 500,
          'top_p': 1,
          'stream': false,
        },
      );

      // Extract response
      final choices = response.data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No response from Groq');
      }

      final assistantMessage = choices.first['message'];
      final responseText = assistantMessage['content']?.toString().trim() ?? '';

      if (responseText.isEmpty) {
        throw Exception('Empty response from Groq');
      }

      // Add AI response to history
      _chatHistory.add({
        'role': 'assistant',
        'content': responseText,
      });

      // Limit history to last 10 messages (prevent context overflow)
      if (_chatHistory.length > 21) { // system + 10 exchanges
        // Keep system prompt and last 10 exchanges
        final systemPrompt = _chatHistory.first;
        final recentMessages = _chatHistory.skip(_chatHistory.length - 20).toList();
        _chatHistory.clear();
        _chatHistory.add(systemPrompt);
        _chatHistory.addAll(recentMessages);
      }

      debugPrint('Received response from Groq: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...');

      return responseText;
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      debugPrint('Groq API Error: $errorMsg');
      debugPrint('Status Code: ${e.response?.statusCode}');

      // Remove last user message since it failed
      if (_chatHistory.isNotEmpty && _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }

      // Rethrow with user-friendly message
      throw GroqException(errorMsg);
    } catch (e) {
      debugPrint('Error sending message to Groq: $e');

      // Remove last user message since it failed
      if (_chatHistory.isNotEmpty && _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }

      throw GroqException('An unexpected error occurred. Please try again.');
    }
  }

  /// Update system prompt with medication context
  void _updateSystemPromptWithContext(String medicationContext) {
    if (_chatHistory.isEmpty) return;

    // Update system prompt with context
    _chatHistory[0] = {
      'role': 'system',
      'content': '''${_getSystemPrompt()}

CURRENT USER CONTEXT:
$medicationContext

IMPORTANT: Use this context to provide personalized advice. Reference their specific medications when relevant.'''
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
