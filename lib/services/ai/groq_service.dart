import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/groq_config.dart';
import '../settings/settings_service.dart';
import 'ai_service.dart';

class GroqService implements AIService {
  final http.Client _client;
  
  GroqService({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  @override
  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) return '';

    if (_apiKey.isEmpty) {
      return "Configuration Error: Groq API Key is missing.";
    }

    try {
      final url = Uri.parse('${GroqConfig.baseUrl}/chat/completions');
      final model = SettingsService.aiModel;
      final temperature = SettingsService.temperature;
      
      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': _applyStyle(message)}
          ],
          'temperature': temperature,
          'stream': false,
        }),
      ).timeout(GroqConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return _handleError(response.statusCode, response.body);
      }
    } on SocketException {
      return "Network Error: Please check your internet connection.";
    } catch (e) {
      return "Error: Something went wrong. Please try again.";
    }
  }

  @override
  Stream<String> streamMessage(String message) async* {
    if (_apiKey.isEmpty) {
      yield "Error: Groq API Key is missing.";
      return;
    }

    final url = Uri.parse('${GroqConfig.baseUrl}/chat/completions');
    final request = http.Request('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    });

    request.body = jsonEncode({
      'model': SettingsService.aiModel,
      'messages': [{'role': 'user', 'content': _applyStyle(message)}],
      'temperature': SettingsService.temperature,
      'stream': true,
    });

    try {
      final response = await _client.send(request).timeout(GroqConfig.timeout);
      
      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield _handleError(response.statusCode, body);
        return;
      }

      String buffer = "";
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') return;
            
            try {
              final json = jsonDecode(data);
              final content = json['choices'][0]['delta']['content'];
              if (content != null) yield content.toString();
            } catch (e) {
              debugPrint("Error decoding stream: $e");
            }
          }
        }
      }
    } catch (e) {
      yield "Error: Connection lost.";
    }
  }

  String _applyStyle(String message) {
    final style = SettingsService.responseStyle;
    if (style == 'Concise') return "Answer as briefly as possible: $message";
    if (style == 'Creative') return "Be very creative and descriptive: $message";
    if (style == 'Precise') return "Provide a very precise and technical answer: $message";
    return message;
  }

  String _handleError(int statusCode, String body) {
    if (statusCode == 401) return "Auth Error: Invalid API key.";
    if (statusCode == 429) return "Rate Limit: Too many requests.";
    try {
      final data = jsonDecode(body);
      return "AI Error: ${data['error']['message']}";
    } catch (_) {
      return "AI Error: Unexpected response ($statusCode)";
    }
  }
}
