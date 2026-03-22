import 'package:equatable/equatable.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/models/chat_session.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.pendingAttachments = const [],
    this.sessions = const [],
    this.activeSessionId,
    this.searchQuery = '',
    this.error,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final List<ChatAttachment> pendingAttachments;
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final String searchQuery;
  final String? error;

  List<ChatSession> get filteredSessions {
    if (searchQuery.isEmpty) return sessions;
    return sessions
        .where(
          (s) => s.title.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  ChatSession? get activeSession {
    if (activeSessionId == null) return null;
    return sessions.where((s) => s.id == activeSessionId).firstOrNull;
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        pendingAttachments,
        sessions,
        activeSessionId,
        searchQuery,
        error,
      ];

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    List<ChatAttachment>? pendingAttachments,
    List<ChatSession>? sessions,
    String? Function()? activeSessionId,
    String? searchQuery,
    String? Function()? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
      sessions: sessions ?? this.sessions,
      activeSessionId:
          activeSessionId != null ? activeSessionId() : this.activeSessionId,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error != null ? error() : this.error,
    );
  }
}
