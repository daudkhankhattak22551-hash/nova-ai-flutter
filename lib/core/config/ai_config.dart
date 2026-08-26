/// Configuration class for AI Service Integration.
class AIConfig {
  AIConfig._();

  /// Official Google Gemini API Base URL
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  /// Sahi model name 'gemini-1.5-flash' hai.
  /// Note: Dash (-) ka istemal karein, space ka nahi.
  static const String model = 'gemini-1.5-flash'; 
  
  /// Connection timeout in milliseconds.
  static const int connectionTimeout = 30000;
}
