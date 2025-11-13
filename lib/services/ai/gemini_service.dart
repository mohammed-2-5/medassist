import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/core/constants/api_constants.dart';

/// Message model for chat history
class ChatMessage {

  ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  Map<String, dynamic> toJson() {
    return {
      'role': isUser ? 'user' : 'model',
      'parts': [
        {'text': text}
      ]
    };
  }
}

/// Service for interacting with Google Gemini AI via REST API
/// Provides medication-related assistance and general health information
class GeminiService {
  factory GeminiService() => _instance;
  GeminiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
  }
  static final GeminiService _instance = GeminiService._internal();

  late final Dio _dio;
  final List<ChatMessage> _chatHistory = [];
  bool _initialized = false;

  /// Initialize Gemini AI service with system prompt
  void initialize() {
    if (_initialized) return;

    // Add system prompt as first message
    _chatHistory.clear();
    _chatHistory.add(ChatMessage(
      text: _getSystemPrompt(),
      isUser: false,
    ));

    _initialized = true;
    debugPrint('Gemini AI service initialized with model: ${ApiConstants.geminiModel}');
  }

  /// Get system prompt that defines the AI assistant's role
  String _getSystemPrompt() {
    return '''
You are a helpful medical assistant AI for a medication reminder app called "Med Assist".
Your role is to provide accurate, helpful information about medications, health, and wellness.

IMPORTANT GUIDELINES:
1. Always prioritize safety - remind users to consult healthcare professionals for serious issues
2. Provide clear, concise, and easy-to-understand information
3. Be empathetic and supportive
4. Never diagnose conditions or prescribe medications
5. Focus on:
   - Medication information (uses, side effects, interactions)
   - General health tips
   - Medication adherence advice
   - When to seek professional help
6. If asked about something outside your expertise, acknowledge it and suggest consulting a healthcare provider

Keep responses concise (2-3 paragraphs maximum unless asked for more detail).
Use bullet points for lists to improve readability.
Always end with "Is there anything else I can help you with?" when appropriate.''';
  }

  /// Send a message and get AI response
  Future<String> sendMessage(String message) async {
    try {
      if (!_initialized) {
        initialize();
      }

      final userMessage = message.trim();
      if (userMessage.isEmpty) {
        return 'Please enter a message.';
      }

      debugPrint('Sending message to Gemini: $userMessage');

      // Add user message to history
      _chatHistory.add(ChatMessage(text: userMessage, isUser: true));

      // Prepare API request
      const endpoint = '/models/${ApiConstants.geminiModel}:generateContent';

      final contents = _chatHistory.map((m) => m.toJson()).toList();

      final response = await _dio.post(
        endpoint,
        queryParameters: {'key': ApiConstants.geminiApiKey},
        data: {'contents': contents},
      );

      // Extract response text
      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response from Gemini');
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      final responseText = parts.first['text']?.toString().trim() ?? '';

      if (responseText.isEmpty) {
        throw Exception('Empty response text from Gemini');
      }

      // Add AI response to history
      _chatHistory.add(ChatMessage(text: responseText, isUser: false));

      debugPrint('Received response from Gemini: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...');

      return responseText;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message']?.toString() ??
          e.message ??
          'Unknown error';

      debugPrint('Gemini API Error: $errorMsg');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');

      // Remove the last user message since it failed
      if (_chatHistory.isNotEmpty && _chatHistory.last.isUser) {
        _chatHistory.removeLast();
      }

      // Return user-friendly error message based on error type
      if (errorMsg.contains('API key') || errorMsg.contains('api_key')) {
        return "I'm having trouble connecting. Please check the API key configuration.";
      } else if (errorMsg.contains('quota') || errorMsg.contains('limit') || errorMsg.contains('429')) {
        return "I've reached my usage limit for now. Please try again later.";
      } else if (errorMsg.contains('safety') || errorMsg.contains('blocked')) {
        return "I can't respond to that question due to safety guidelines. Please rephrase your question.";
      } else if (errorMsg.contains('not found') || errorMsg.contains('404')) {
        return 'The AI model is temporarily unavailable. Please try again later.';
      } else {
        return "I'm having trouble responding right now. Please try again in a moment.";
      }
    } catch (e) {
      debugPrint('Error sending message to Gemini: $e');

      // Remove the last user message since it failed
      if (_chatHistory.isNotEmpty && _chatHistory.last.isUser) {
        _chatHistory.removeLast();
      }

      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Clear chat history and start fresh
  void clearHistory() {
    _chatHistory.clear();
    _initialized = false;
    initialize();
    debugPrint('Chat history cleared');
  }

  /// Get suggested prompts for common questions
  List<String> getSuggestedPrompts() {
    return [
      'What medications can help with headaches?',
      'Tell me about drug interactions',
      'How should I store my medications?',
      'What are common side effects of antibiotics?',
      'When should I take medication with food?',
      'How can I improve medication adherence?',
      'What should I do if I miss a dose?',
      'Are there any natural alternatives?',
    ];
  }

  /// Get current chat history (for debugging/testing)
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);

  /// Dispose resources
  void dispose() {
    _chatHistory.clear();
    _initialized = false;
    debugPrint('Gemini service disposed');
  }
}
