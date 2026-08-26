import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/config/secure_api_config.dart';

class ImageGenerationService {
  /// Uses the current official Pollinations AI API
  static const String _baseUrl = 'https://gen.pollinations.ai/image/';

  Future<List<Uint8List>> generateImage({
    required String prompt,
    String style = "Realistic",
    String aspectRatio = "1:1",
    int samples = 1,
    String quality = "HD",
  }) async {
    // 1. Read key from String.fromEnvironment via SecureApiConfig
    final apiKey = SecureApiConfig.pollinationsApiKey;

    // 14. Verify API key is not empty
    if (apiKey.isEmpty) {
      throw Exception("Configuration Error: POLLINATIONS_API_KEY is not set.");
    }

    // 16. Log key configuration status (not the key itself)
    developer.log("Pollinations API key configured: ${apiKey.isNotEmpty}");

    if (prompt.trim().isEmpty) {
      throw Exception("Prompt cannot be empty");
    }

    try {
      final List<Uint8List> images = [];
      
      // 8. URL-encode ONLY the prompt path correctly
      final encodedPrompt = Uri.encodeComponent(prompt);
      
      // 5 & 10. Construct URL with ONLY model=flux
      // https://gen.pollinations.ai/image/{encodedPrompt}?model=flux
      final imageUrl = "$_baseUrl$encodedPrompt?model=flux";

      for (int i = 0; i < samples; i++) {
        // 11. Use http.get with Authorization header
        final response = await http.get(
          Uri.parse(imageUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ).timeout(const Duration(seconds: 120)); // 12. 120s timeout

        // 13. Check for HTTP 200
        if (response.statusCode == 200) {
          if (response.bodyBytes.isEmpty) {
             throw Exception("Pollinations returned 200 but body was empty.");
          }
          images.add(response.bodyBytes);
        } else if (response.statusCode == 402) {
          // Handle Insufficient balance (Payment Required)
          developer.log("Pollinations Error Status: 402");
          developer.log("Pollinations Error Body: ${response.body}");
          throw Exception("Image generation requires Pollinations balance. Please add pollen/credits to your Pollinations account and try again.");
        } else {
          // MOST IMPORTANT DEBUGGING REQUIREMENT:
          // Log and return exception with status code and body
          developer.log("Pollinations Error Status: ${response.statusCode}");
          developer.log("Pollinations Error Body: ${response.body}");
          
          throw Exception("Pollinations HTTP ${response.statusCode}: ${response.body}");
        }
      }
      
      return images;
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception("Network Error: ${e.message}");
      }
      rethrow;
    }
  }
}
