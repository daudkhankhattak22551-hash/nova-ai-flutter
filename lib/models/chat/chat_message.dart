import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String text;
  
  @HiveField(1)
  final bool isUser;
  
  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  int feedback; // 0: none, 1: liked, 2: disliked

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.feedback = 0,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 0;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      text: fields[0] as String,
      isUser: fields[1] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      feedback: fields[3] == null ? 0 : fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.isUser)
      ..writeByte(2)
      ..write(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.feedback);
  }
}
