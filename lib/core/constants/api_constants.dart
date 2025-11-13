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
  static const String geminiModel = 'gemini-2.0-flash-exp';

  /// Gemini API Base URL
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // ============================================================================
  // GROQ AI - Primary (10× faster, better free tier)
  // ============================================================================
  /// Groq API Key (loaded from .env)
  /// Get your free key at: https://console.groq.com/keys
  /// Free tier: 14,400 requests/day (no credit card required!)
  static String get groqApiKey => dotenv.get('GROQ_API_KEY', fallback: '');

  /// Groq Model (Llama 3.1 8B Instant - fastest, recommended)
  /// Alternative models: 'llama-3.1-70b-versatile', 'mixtral-8x7b-32768'
  static const String groqModel = 'llama-3.1-8b-instant';

  /// Groq API Base URL (OpenAI-compatible)
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  // ============================================================================
  // HUGGING FACE - Fallback #3 (truly unlimited, but slower)
  // ============================================================================
  /// HuggingFace API Key (loaded from .env)
  /// Get your free token at: https://huggingface.co/settings/tokens
  /// Free tier: Unlimited requests (rate limited)
  static String get huggingFaceApiKey => dotenv.get('HUGGINGFACE_API_KEY', fallback: '');

  /// HuggingFace Model (Mistral 7B Instruct)
  static const String huggingFaceModel = 'mistralai/Mistral-7B-Instruct-v0.2';

  /// HuggingFace API Base URL
  static const String huggingFaceBaseUrl = 'https://router.huggingface.co/hf-inference';
}
