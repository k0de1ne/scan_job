import 'package:equatable/equatable.dart';
import 'package:scan_job/chat/models/chat_message.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.pendingAttachments = const [],
    this.error,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final List<ChatAttachment> pendingAttachments;
  final String? error;

  @override
  List<Object?> get props => [status, messages, pendingAttachments, error];

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    List<ChatAttachment>? pendingAttachments,
    String? Function()? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
      error: error != null ? error() : this.error,
    );
  }
}
