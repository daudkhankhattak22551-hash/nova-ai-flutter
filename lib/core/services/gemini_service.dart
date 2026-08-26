import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/secure_api_config.dart';
import 'ai_config.dart';

class GeminiService {
  GeminiService();

  Future<String> generateResponse(String message) async {
    final apiKey = SecureApiConfig.geminiApiKey;

    if (apiKey.isEmpty) {
      throw Exception(
        'API key is missing. Please configure GEMINI_API_KEY.',
      );
    }

    final uri = Uri.parse(
      '${AIConfig.baseUrl}/models/${AIConfig.model}:generateContent',
    );

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': message,
              },
            ],
          },
        ],
      }),
    )
        .timeout(AIConfig.receiveTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final candidates = data['candidates'];

      if (candidates != null &&
          candidates.isNotEmpty) {
        final parts =
        candidates[0]['content']?['parts'];

        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text']?.toString() ??
              'No response received.';
        }
      }

      throw Exception('Gemini returned an empty response.');
    }

    if (response.statusCode == 400) {
      throw Exception(
        'Invalid request: ${response.body}',
      );
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Gemini API key is invalid or does not have permission.',
      );
    }

    if (response.statusCode == 429) {
      throw Exception(
        'Gemini API rate limit reached. Please try again later.',
      );
    }

    throw Exception(
      'Gemini API error ${response.statusCode}: ${response.body}',
    );
  }
}