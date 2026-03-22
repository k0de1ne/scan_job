import 'package:scan_job/chat/models/chat_message.dart';

abstract class ChatRepository {
  void updateConfig({
    String? baseUrl,
    String? apiKey,
    String? modelName,
    String? deviceId,
  });

  Stream<ChatMessage> sendMessage({
    required String text,
    List<ChatMessage> history = const [],
    List<ChatAttachment> attachments = const [],
  });

  List<Map<String, dynamic>> getTools();
}
