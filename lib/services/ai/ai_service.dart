/// Abstract class defining the contract for AI operations.
abstract class AIService {
  /// Sends a message to the AI and returns the full response.
  Future<String> sendMessage(String message);

  /// Sends a message to the AI and returns a stream of response chunks.
  Stream<String> streamMessage(String message);
}
