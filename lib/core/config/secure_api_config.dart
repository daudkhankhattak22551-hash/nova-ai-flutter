class SecureApiConfig {
  SecureApiConfig._();

  /// Gemini API Key (Optional/Placeholder).
  /// Hardcoded key removed for security. Use --dart-define=GEMINI_API_KEY=your_key
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Pollinations AI API Key.
  /// Used for Image Generation via gen.pollinations.ai
  static const String pollinationsApiKey = String.fromEnvironment('POLLINATIONS_API_KEY');

  /// Validation for Gemini.
  static bool get isApiKeyPresent => geminiApiKey.isNotEmpty;

  /// Validation for Pollinations.
  static bool get isPollinationsApiKeyPresent => pollinationsApiKey.isNotEmpty;
}
