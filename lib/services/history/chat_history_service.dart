import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/chat/chat_message.dart';
import '../../models/history/chat_history_model.dart';
import 'package:uuid/uuid.dart';

class ChatHistoryService {
  static const String _boxName = 'chat_history_box';
  
  static bool _isInitialized = false;
  static Future<void>? _initFuture;

  static Future<void> init() async {
    if (_isInitialized && Hive.isBoxOpen(_boxName)) return;

    if (_initFuture != null) return _initFuture;

    _initFuture = _performInit();
    return _initFuture;
  }

  static Future<void> _performInit() async {
    try {
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ChatMessageAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ChatHistoryAdapter());
      
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<ChatHistory>(_boxName).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('ChatHistoryService: Hive.openBox timed out');
            throw Exception('Chat history box timeout');
          },
        );
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('ChatHistoryService initialization failed: $e');
      rethrow;
    } finally {
      _initFuture = null;
    }
  }

  static bool get isReady => _isInitialized && Hive.isBoxOpen(_boxName);

  Box<ChatHistory> get _box {
    return Hive.box<ChatHistory>(_boxName);
  }

  List<ChatHistory> getAllHistory() {
    if (!isReady) return [];
    try {
      final history = _box.values.toList();
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return history;
    } catch (e) {
      debugPrint('Error getting all history: $e');
      return [];
    }
  }

  Future<ChatHistory> createNewChat([String? firstMessage]) async {
    if (!isReady) await init();
    
    final id = const Uuid().v4();
    final now = DateTime.now();
    final title = firstMessage != null 
        ? (firstMessage.length > 30 ? '${firstMessage.substring(0, 27)}...' : firstMessage)
        : "New Chat";
        
    final newChat = ChatHistory(
      id: id,
      title: title,
      lastMessage: firstMessage ?? '',
      timestamp: now,
      createdAt: now,
      messages: [],
      messageCount: 0,
    );
    await _box.put(id, newChat);
    return newChat;
  }

  Future<void> saveMessage(String chatId, ChatMessage message) async {
    if (!isReady) await init();
    final chat = _box.get(chatId);
    if (chat != null) {
      final updatedMessages = List<ChatMessage>.from(chat.messages)..add(message);
      chat.messages = updatedMessages;
      chat.lastMessage = message.text;
      chat.timestamp = DateTime.now();
      chat.messageCount = updatedMessages.length;
      
      if (chat.title == "New Chat" && message.isUser) {
        chat.title = message.text.length > 30 
            ? '${message.text.substring(0, 27)}...' 
            : message.text;
      }
      
      await _box.put(chatId, chat);
    }
  }

  Future<void> updateMessageFeedback(String chatId, int messageIndex, int feedback) async {
    if (!isReady) await init();
    final chat = _box.get(chatId);
    if (chat != null && messageIndex >= 0 && messageIndex < chat.messages.length) {
      final updatedMessages = List<ChatMessage>.from(chat.messages);
      final msg = updatedMessages[messageIndex];
      updatedMessages[messageIndex] = ChatMessage(
        text: msg.text,
        isUser: msg.isUser,
        timestamp: msg.timestamp,
        feedback: feedback,
      );
      chat.messages = updatedMessages;
      await _box.put(chatId, chat);
    }
  }

  Future<void> removeLastMessage(String chatId) async {
    if (!isReady) await init();
    final chat = _box.get(chatId);
    if (chat != null && chat.messages.isNotEmpty) {
      final updatedMessages = List<ChatMessage>.from(chat.messages)..removeLast();
      chat.messages = updatedMessages;
      chat.messageCount = updatedMessages.length;
      if (updatedMessages.isNotEmpty) {
        chat.lastMessage = updatedMessages.last.text;
      } else {
        chat.lastMessage = '';
      }
      chat.timestamp = DateTime.now();
      await _box.put(chatId, chat);
    }
  }

  Future<void> updateChatTitle(String chatId, String newTitle) async {
    if (!isReady) await init();
    final chat = _box.get(chatId);
    if (chat != null) {
      chat.title = newTitle;
      chat.timestamp = DateTime.now();
      await _box.put(chatId, chat);
    }
  }

  Future<void> deleteChat(String chatId) async {
    if (!isReady) await init();
    await _box.delete(chatId);
  }

  Future<void> deleteAllHistory() async {
    if (!isReady) await init();
    await _box.clear();
  }

  Future<void> clearMessages(String chatId) async {
    if (!isReady) await init();
    final chat = _box.get(chatId);
    if (chat != null) {
      chat.messages = [];
      chat.lastMessage = '';
      chat.messageCount = 0;
      chat.timestamp = DateTime.now();
      await _box.put(chatId, chat);
    }
  }

  ChatHistory? getChat(String chatId) {
    if (!isReady) return null;
    return _box.get(chatId);
  }
}
