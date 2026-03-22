import 'package:equatable/equatable.dart';
import 'package:scan_job/chat/models/chat_message.dart';

class ChatSession extends Equatable {
  const ChatSession({
    required this.id,
    required this.title,
    this.messages = const [],
    required this.createdAt,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, messages, createdAt];

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
