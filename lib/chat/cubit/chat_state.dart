import 'package:equatable/equatable.dart';
import 'package:scan_job/chat/models/chat_message.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;

  @override
  List<Object?> get props => [status, messages, error];

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}
