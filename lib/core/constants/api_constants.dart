import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Constants for external services
/// API Keys are loaded from .env file for security
class ApiConstants {
  ApiConstants._();

  // ============================================================================
  // GEMINI AI (Google) - Fallback #2
  // ============================================================================
  /// Gemini AI API Key (loaded from .env)
  static String get geminiApiKey => dotenv.get('GEMINI_API_KEY', fallback: '');

  /// Gemini Model to use (free tier)
  static const String geminiModel = 'gemini-2.5-flash';

  /// Gemini API Base URL
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // ============================================================================
  // GROQ AI - Primary (10× faster, better free tier)
  // ============================================================================
  /// Groq API Key (loaded from .env)
  /// Get your free key at: https://console.groq.com/keys
  /// Free tier: 14,400 requests/day (no credit card required!)
  static String get groqApiKey => dotenv.get('GROQ_API_KEY', fallback: '');

  /// Primary model: Llama 3.3 70B — strong medical reasoning, clean Arabic,
  /// no Chinese-token leakage (Qwen3/Kimi K2 occasionally emit CJK chars).
  /// Fallback: Llama 4 Scout 17B — newer Meta model, also CJK-clean.
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String groqFallbackModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Groq API Base URL (OpenAI-compatible)
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  // ============================================================================
  // HUGGING FACE - Fallback #3 (truly unlimited, but slower)
  // ============================================================================
  /// HuggingFace API Key (loaded from .env)
  /// Get your free token at: https://huggingface.co/settings/tokens
  /// Free tier: Unlimited requests (rate limited)
  static String get huggingFaceApiKey =>
      dotenv.get('HUGGINGFACE_API_KEY', fallback: '');

  /// HuggingFace Model (Mistral 7B Instruct)
  static const String huggingFaceModel = 'mistralai/Mistral-7B-Instruct-v0.2';

  /// HuggingFace API Base URL
  static const String huggingFaceBaseUrl =
      'https://router.huggingface.co/hf-inference';
}
