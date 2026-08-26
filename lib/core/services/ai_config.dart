
class AIConfig {
  AIConfig._();


  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';


  static const String model = 'gemini-1.5-flash';


  static const Duration connectionTimeout =
  Duration(seconds: 30);


  static const Duration receiveTimeout =
  Duration(seconds: 60);
}