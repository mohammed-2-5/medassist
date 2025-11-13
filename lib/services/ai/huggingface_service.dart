import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/core/constants/api_constants.dart';

/// HuggingFace Inference API Service
/// Uses Mistral 7B Instruct model
///
/// Free Tier: Unlimited requests (rate limited, may have queues)
/// Speed: 5-10 seconds (slower but always works)
/// Use case: Final fallback when other APIs fail
class HuggingFaceService {
  factory HuggingFaceService() => _instance;

  HuggingFaceService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.huggingFaceBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${ApiConstants.huggingFaceApiKey}',
        'Content-Type': 'application/json',
      },
    ));
  }
  static final HuggingFaceService _instance = HuggingFaceService._internal();

  late final Dio _dio;
  bool _initialized = false;

  /// Initialize service
  void initialize() {
    if (_initialized) return;
    _initialized = true;
    debugPrint('HuggingFace service initialized with model: ${ApiConstants.huggingFaceModel}');
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

      debugPrint('Sending message to HuggingFace: $userMessage');

      // Build prompt with context
      final prompt = _buildPrompt(userMessage, medicationContext);

      // Call Inference API
      final response = await _dio.post(
        '/models/${ApiConstants.huggingFaceModel}',
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 500,
            'temperature': 0.7,
            'top_p': 0.95,
            'return_full_text': false,
          },
          'options': {
            'wait_for_model': true, // Wait if model is loading
          },
        },
      );

      // Parse response
      final responseData = response.data;

      if (responseData is List && responseData.isNotEmpty) {
        final firstResult = responseData.first;
        if (firstResult is Map && firstResult['generated_text'] != null) {
          final responseText = firstResult['generated_text'].toString().trim();

          if (responseText.isEmpty) {
            throw Exception('Empty response from HuggingFace');
          }

          debugPrint('Received response from HuggingFace: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...');
          return responseText;
        }
      }

      throw Exception('Invalid response format from HuggingFace');
    } on DioException catch (e) {
      final errorMsg = _parseErrorMessage(e);
      debugPrint('HuggingFace API Error: $errorMsg');
      debugPrint('Status Code: ${e.response?.statusCode}');

      throw HuggingFaceException(errorMsg);
    } catch (e) {
      debugPrint('Error sending message to HuggingFace: $e');
      throw HuggingFaceException('An unexpected error occurred. Please try again.');
    }
  }

  /// Build prompt with medical assistant context
  String _buildPrompt(String userMessage, String? medicationContext) {
    final systemPrompt = '''You are a helpful medical assistant AI. Provide accurate, concise information about medications and health.

GUIDELINES:
- Always prioritize safety
- Recommend consulting healthcare professionals
- Never diagnose or prescribe
- Be clear and supportive

${medicationContext != null && medicationContext.isNotEmpty ? 'USER CONTEXT:\n$medicationContext\n\n' : ''}USER QUESTION: $userMessage

ASSISTANT:''';

    return systemPrompt;
  }

  /// Parse error message
  String _parseErrorMessage(DioException e) {
    final errorData = e.response?.data;

    if (errorData is Map && errorData['error'] != null) {
      return errorData['error'].toString();
    }

    final statusCode = e.response?.statusCode;

    if (statusCode == 401) {
      return 'Invalid HuggingFace token. Please check configuration.';
    } else if (statusCode == 429) {
      return 'Rate limit exceeded. Please try again later.';
    } else if (statusCode == 503) {
      return 'Model is loading. This may take a few moments...';
    } else if (statusCode != null) {
      return 'API error ($statusCode). Please try again.';
    }

    return e.message ?? 'Network error. Please check your connection.';
  }

  /// Check if service is available
  Future<bool> isAvailable() async {
    try {
      // Try a simple test request
      final response = await _dio.post(
        '/models/${ApiConstants.huggingFaceModel}',
        data: {
          'inputs': 'Test',
          'parameters': {'max_new_tokens': 10},
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('HuggingFace availability check failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _initialized = false;
    debugPrint('HuggingFace service disposed');
  }
}

/// Custom exception for HuggingFace API errors
class HuggingFaceException implements Exception {
  HuggingFaceException(this.message);
  final String message;

  @override
  String toString() => message;
}
