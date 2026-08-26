class GroqConfig {
  GroqConfig._();

  static const String baseUrl = 'https://api.groq.com/openai/v1';
  
  /// Currently supported Groq model
  static const String model = 'llama-3.3-70b-versatile';

  static const Duration timeout = Duration(seconds: 30);
}
