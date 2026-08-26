import 'package:hive/hive.dart';
import '../chat/chat_message.dart';

@HiveType(typeId: 1)
class ChatHistory extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String lastMessage;
  
  @HiveField(3)
  DateTime timestamp;
  
  @HiveField(4)
  List<ChatMessage> messages;
  
  @HiveField(5)
  int messageCount;

  @HiveField(6)
  final DateTime createdAt;

  ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.messages,
    required this.createdAt,
    this.messageCount = 0,
  });

  ChatHistory copyWith({
    String? title,
    String? lastMessage,
    DateTime? timestamp,
    List<ChatMessage>? messages,
    int? messageCount,
    DateTime? createdAt,
  }) {
    return ChatHistory(
      id: id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}

class ChatHistoryAdapter extends TypeAdapter<ChatHistory> {
  @override
  final int typeId = 1;

  @override
  ChatHistory read(BinaryReader reader) {
    return ChatHistory(
      id: reader.readString(),
      title: reader.readString(),
      lastMessage: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      messages: reader.readList().cast<ChatMessage>(),
      messageCount: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, ChatHistory obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.lastMessage);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeList(obj.messages);
    writer.writeInt(obj.messageCount);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
