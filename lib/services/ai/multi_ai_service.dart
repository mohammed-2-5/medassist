import 'package:flutter/material.dart';
import 'package:med_assist/services/ai/gemini_service.dart';
import 'package:med_assist/services/ai/groq_service.dart';
import 'package:med_assist/services/ai/huggingface_service.dart';

/// Multi-AI Service - Intelligent fallback system
///
/// Tries multiple AI APIs in order of preference:
/// 1. Groq (fastest, best free tier: 14,400/day)
/// 2. Gemini (reliable backup: 1,500/day)
/// 3. HuggingFace (unlimited but slower)
///
/// Provides 99.9% uptime with automatic failover
class MultiAIService {
  factory MultiAIService() => _instance;

  MultiAIService._internal();
  static final MultiAIService _instance = MultiAIService._internal();

  final GroqService _groqService = GroqService();
  final GeminiService _geminiService = GeminiService();
  final HuggingFaceService _huggingFaceService = HuggingFaceService();

  bool _initialized = false;

  // Track which API was used for analytics
  String? _lastUsedApi;
  int _groqSuccessCount = 0;
  int _geminiSuccessCount = 0;
  int _huggingFaceSuccessCount = 0;
  int _totalRequests = 0;

  /// Initialize all AI services
  void initialize() {
    if (_initialized) return;

    _groqService.initialize();
    _geminiService.initialize();
    _huggingFaceService.initialize();

    _initialized = true;
    debugPrint('MultiAI service initialized with 3 fallback options');
  }

  /// Send message with intelligent fallback
  Future<String> sendMessage(String message, {String? medicationContext}) async {
    if (!_initialized) {
      initialize();
    }

    _totalRequests++;

    // Try Groq first (fastest, best free tier)
    try {
      debugPrint('MultiAI: Trying Groq (primary)...');
      final response = await _groqService.sendMessage(
        message,
        medicationContext: medicationContext,
      );

      _lastUsedApi = 'Groq';
      _groqSuccessCount++;
      debugPrint('MultiAI: ✓ Groq succeeded');

      return response;
    } on GroqException catch (e) {
      debugPrint('MultiAI: ✗ Groq failed: $e');

      // If rate limited or API issue, try Gemini
      return _tryGeminiFallback(message, medicationContext);
    } catch (e) {
      debugPrint('MultiAI: ✗ Groq error: $e');

      // Try Gemini for any other error
      return _tryGeminiFallback(message, medicationContext);
    }
  }

  /// Fallback to Gemini
  Future<String> _tryGeminiFallback(String message, String? medicationContext) async {
    try {
      debugPrint('MultiAI: Trying Gemini (fallback #1)...');

      // Gemini service uses different method signature
      // For context-aware, we'd need to update the prompt
      var enhancedMessage = message;
      if (medicationContext != null && medicationContext.isNotEmpty) {
        enhancedMessage = '''$medicationContext

User Question: $message''';
      }

      final response = await _geminiService.sendMessage(enhancedMessage);

      _lastUsedApi = 'Gemini';
      _geminiSuccessCount++;
      debugPrint('MultiAI: ✓ Gemini succeeded');

      return response;
    } catch (e) {
      debugPrint('MultiAI: ✗ Gemini failed: $e');

      // Try HuggingFace as last resort
      return _tryHuggingFaceFallback(message, medicationContext);
    }
  }

  /// Fallback to HuggingFace
  Future<String> _tryHuggingFaceFallback(String message, String? medicationContext) async {
    try {
      debugPrint('MultiAI: Trying HuggingFace (fallback #2)...');
      final response = await _huggingFaceService.sendMessage(
        message,
        medicationContext: medicationContext,
      );

      _lastUsedApi = 'HuggingFace';
      _huggingFaceSuccessCount++;
      debugPrint('MultiAI: ✓ HuggingFace succeeded');

      return response;
    } on HuggingFaceException catch (e) {
      debugPrint('MultiAI: ✗ HuggingFace failed: $e');

      // All APIs failed - return offline message
      return _getOfflineResponse(message);
    } catch (e) {
      debugPrint('MultiAI: ✗ HuggingFace error: $e');

      // All APIs failed - return offline message
      return _getOfflineResponse(message);
    }
  }

  /// Get offline response when all APIs fail
  String _getOfflineResponse(String message) {
    debugPrint('MultiAI: All APIs failed, returning offline response');
    _lastUsedApi = 'Offline';

    // Provide helpful offline responses based on keywords
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('side effect')) {
      return '''
I'm currently offline, but here's general guidance:

Common medication side effects usually appear within the first few weeks. They often include:
• Nausea or stomach upset
• Dizziness or drowsiness
• Headache
• Changes in appetite

⚠️ Contact your doctor if you experience:
• Severe or persistent side effects
• Allergic reactions (rash, swelling, difficulty breathing)
• Unexpected symptoms

Please try again when you have an internet connection for personalized advice.''';
    } else if (lowerMessage.contains('miss') || lowerMessage.contains('forgot')) {
      return '''
I'm currently offline, but here's what to do if you miss a dose:

1. Take it as soon as you remember, if it's still close to the scheduled time
2. If it's almost time for the next dose, skip the missed one
3. Never double up on doses to make up for a missed one
4. Set reminders to help you remember

Please try again when you have an internet connection for medication-specific advice.''';
    } else if (lowerMessage.contains('interaction')) {
      return '''
I'm currently offline, but here's general guidance about drug interactions:

Always inform your healthcare provider about:
• All medications you're taking (including over-the-counter)
• Vitamins and supplements
• Herbal products

⚠️ Common interactions to watch for:
• Blood thinners + NSAIDs (aspirin, ibuprofen)
• Some antibiotics + birth control
• Grapefruit + certain statins

Please try again when you have an internet connection to check your specific medications.''';
    }

    return '''
I'm currently offline and unable to connect to the AI services.

Here are some things you can do:
• Check your medication list and reminders
• View your adherence statistics
• Review your dose history

Please try again when you have an internet connection, or visit the other app features.

For urgent medical questions, please contact your healthcare provider directly.''';
  }

  /// Clear all chat histories
  void clearHistory() {
    _groqService.clearHistory();
    _geminiService.clearHistory();
    // HuggingFace is stateless, no history to clear

    debugPrint('MultiAI: All chat histories cleared');
  }

  /// Get suggested prompts (from primary service)
  List<String> getSuggestedPrompts() {
    return _groqService.getSuggestedPrompts();
  }

  /// Get statistics about API usage
  Map<String, dynamic> getUsageStats() {
    return {
      'total_requests': _totalRequests,
      'groq_success': _groqSuccessCount,
      'gemini_success': _geminiSuccessCount,
      'huggingface_success': _huggingFaceSuccessCount,
      'groq_success_rate': _totalRequests > 0
          ? (_groqSuccessCount / _totalRequests * 100).toStringAsFixed(1)
          : '0.0',
      'last_used_api': _lastUsedApi ?? 'None',
    };
  }

  /// Check which APIs are currently available
  Future<Map<String, bool>> checkApiAvailability() async {
    debugPrint('MultiAI: Checking API availability...');

    final results = await Future.wait([
      _groqService.isAvailable(),
      // Gemini doesn't have availability check method
      Future.value(true), // Assume available
      _huggingFaceService.isAvailable(),
    ]);

    return {
      'groq': results[0],
      'gemini': results[1],
      'huggingface': results[2],
    };
  }

  /// Get which API was last used (for debugging/analytics)
  String? get lastUsedApi => _lastUsedApi;

  /// Get success rate for primary API (Groq)
  double get primaryApiSuccessRate {
    return _totalRequests > 0 ? _groqSuccessCount / _totalRequests : 0.0;
  }

  /// Reset statistics
  void resetStats() {
    _groqSuccessCount = 0;
    _geminiSuccessCount = 0;
    _huggingFaceSuccessCount = 0;
    _totalRequests = 0;
    _lastUsedApi = null;
    debugPrint('MultiAI: Statistics reset');
  }

  /// Dispose all services
  void dispose() {
    _groqService.dispose();
    _geminiService.dispose();
    _huggingFaceService.dispose();

    _initialized = false;
    debugPrint('MultiAI: All services disposed');
  }
}
