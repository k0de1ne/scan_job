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

  factory ChatState.fromJson(Map<String, dynamic> json) {
    final sessions = (json['sessions'] as List<dynamic>)
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
    final activeSessionId = json['activeSessionId'] as String?;
    final messages = activeSessionId != null
        ? sessions.firstWhere((s) => s.id == activeSessionId).messages
        : <ChatMessage>[];

    return ChatState(
      status: ChatStatus.values[json['status'] as int? ?? ChatStatus.initial.index],
      sessions: sessions,
      activeSessionId: activeSessionId,
      messages: messages,
      searchQuery: json['searchQuery'] as String? ?? '',
    );
  }

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

  Map<String, dynamic> toJson() => {
        'status': status.index,
        'sessions': sessions.map((e) => e.toJson()).toList(),
        'activeSessionId': activeSessionId,
        'searchQuery': searchQuery,
      };

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
