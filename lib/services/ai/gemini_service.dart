import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/services/ai_config.dart';
import '../../core/config/secure_api_config.dart';
import 'ai_service.dart';

/// GeminiService implementation of [AIService].
class GeminiService implements AIService {
  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) return '';

    if (!SecureApiConfig.isApiKeyPresent) {
      return "System configuration error: API Key is missing. Please check secure_api_config.dart";
    }

    try {
      final apiKey = SecureApiConfig.geminiApiKey;
      final url = Uri.parse(
        '${AIConfig.baseUrl}/models/${AIConfig.model}:generateContent?key=$apiKey',
      );

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message}
              ]
            }
          ]
        }),
      ).timeout(AIConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'];
            if (text != null) return text.toString();
          }
        }
        return "I received an empty response. Please try asking something else.";
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error']?['message'] ?? 'Unknown API Error';
          return "AI Error (${response.statusCode}): $errorMessage";
        } catch (_) {
          return "AI service returned an error (Status: ${response.statusCode}).";
        }
      }
    } on SocketException {
      return "No internet connection. Please check your network.";
    } on http.ClientException {
      return "Connection failed. The AI service might be down.";
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  @override
  Stream<String> streamMessage(String message) async* {
    // Basic streaming implementation fallback for Gemini if streaming endpoint not fully integrated
    try {
      final response = await sendMessage(message);
      // Split by words to simulate streaming feel if needed, or just yield full response
      yield response;
    } catch (e) {
      yield "Error: $e";
    }
  }
}
