/// Sanitizes user input + medication context before sending to AI services.
///
/// Mitigates prompt injection by stripping control characters, role markers,
/// and capping length. Content is not executed as instructions, but limiting
/// obvious role-switch tokens reduces the chance of the model being coerced
/// into ignoring the system prompt.
class AiPromptSanitizer {
  AiPromptSanitizer._();

  static const int maxUserMessageLength = 2000;
  static const int maxContextLength = 4000;

  static final RegExp _controlChars = RegExp(
    r'[\u0000-\u0008\u000B-\u001F\u007F]',
  );
  static final RegExp _roleMarkers = RegExp(
    r'(?:^|\n)\s*(?:system|assistant|user)\s*:',
    caseSensitive: false,
  );
  static final RegExp _injectionPhrases = RegExp(
    r'ignore (?:all |previous |the )?(?:instructions|prompts|rules)',
    caseSensitive: false,
  );

  /// Sanitize a user-entered message.
  static String sanitizeUserMessage(String input) {
    var cleaned = input.replaceAll(_controlChars, ' ').trim();
    if (cleaned.length > maxUserMessageLength) {
      cleaned = cleaned.substring(0, maxUserMessageLength);
    }
    return cleaned;
  }

  /// Sanitize injected medication context (stronger scrubbing — user cannot
  /// normally type here, but data may contain untrusted content via OCR).
  static String sanitizeContext(String input) {
    var cleaned = input
        .replaceAll(_controlChars, ' ')
        .replaceAll(_roleMarkers, ' ')
        .replaceAll(_injectionPhrases, '[filtered]')
        .trim();
    if (cleaned.length > maxContextLength) {
      cleaned = cleaned.substring(0, maxContextLength);
    }
    return cleaned;
  }
}
