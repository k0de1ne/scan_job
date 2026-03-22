import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/models/chat_session.dart';
import 'package:scan_job/repositories/chat_repository.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatState());

  final ChatRepository _chatRepository;
  StreamSubscription<ChatMessage>? _subscription;

  Future<String?> _extractText(ChatAttachment attachment) async {
    try {
      final ext = attachment.extension?.toLowerCase();
      if (ext == 'txt') {
        return utf8.decode(attachment.bytes);
      } else if (ext == 'pdf') {
        final document = PdfDocument(inputBytes: attachment.bytes);
        final text = PdfTextExtractor(document).extractText();
        document.dispose();
        return text;
      }
    } catch (e) {
      // Log error or handle it
      return 'Error extracting text: $e';
    }
    return null;
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void createNewChat() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newSession = ChatSession(
      id: newId,
      title: 'New Chat',
      messages: const [],
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        sessions: [newSession, ...state.sessions],
        activeSessionId: () => newId,
        messages: [],
        pendingAttachments: [],
        status: ChatStatus.initial,
      ),
    );
  }

  void selectChat(String id) {
    final session = state.sessions.firstWhere((s) => s.id == id);
    emit(
      state.copyWith(
        activeSessionId: () => id,
        messages: session.messages,
        pendingAttachments: [],
        status: ChatStatus.initial,
      ),
    );
  }

  void deleteChat(String id) {
    final updatedSessions =
        state.sessions.where((s) => s.id != id).toList();
    String? nextActiveId = state.activeSessionId;

    if (state.activeSessionId == id) {
      nextActiveId = updatedSessions.isNotEmpty ? updatedSessions.first.id : null;
    }

    emit(
      state.copyWith(
        sessions: updatedSessions,
        activeSessionId: () => nextActiveId,
        messages: nextActiveId != null
            ? updatedSessions.firstWhere((s) => s.id == nextActiveId).messages
            : [],
      ),
    );
  }

  Future<void> addAttachment(ChatAttachment attachment) async {
    final extractedText = await _extractText(attachment);
    final updatedAttachment = ChatAttachment(
      name: attachment.name,
      bytes: attachment.bytes,
      extension: attachment.extension,
      extractedText: extractedText,
    );
    
    emit(
      state.copyWith(
        pendingAttachments: [...state.pendingAttachments, updatedAttachment],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && state.pendingAttachments.isEmpty) return;

    if (state.activeSessionId == null) {
      createNewChat();
    }

    final attachments = List<ChatAttachment>.from(state.pendingAttachments);
    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    final history = state.messages;
    final updatedMessages = [...state.messages, userMessage];

    _updateSessionMessages(state.activeSessionId!, updatedMessages, text);

    emit(
      state.copyWith(
        messages: updatedMessages,
        pendingAttachments: [],
        status: ChatStatus.loading,
        error: () => null,
      ),
    );

    try {
      final stream = _chatRepository.sendMessage(
        text: text,
        history: history,
        attachments: attachments,
      );

      ChatMessage? lastAiMessage;

      await _subscription?.cancel();
      _subscription = stream.listen(
        (message) {
          final currentMessages = List<ChatMessage>.from(state.messages);
          if (lastAiMessage == null) {
            currentMessages.add(message);
          } else {
            currentMessages[currentMessages.length - 1] = message;
          }
          
          _updateSessionMessages(state.activeSessionId!, currentMessages);
          emit(
            state.copyWith(
              messages: currentMessages,
              status: ChatStatus.loading,
            ),
          );
          lastAiMessage = message;
        },
        onError: (Object error) {
          emit(
            state.copyWith(
              status: ChatStatus.failure,
              error: error.toString,
            ),
          );
        },
        onDone: () {
          emit(state.copyWith(status: ChatStatus.success));
        },
        cancelOnError: true,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          error: e.toString,
        ),
      );
    }
  }

  void _updateSessionMessages(
    String id,
    List<ChatMessage> messages, [
    String? firstMessageText,
  ]) {
    final updatedSessions = state.sessions.map((s) {
      if (s.id == id) {
        var title = s.title;
        if (title == 'New Chat' && firstMessageText != null) {
          title = firstMessageText.length > 30
              ? '${firstMessageText.substring(0, 30)}...'
              : firstMessageText;
        }
        return s.copyWith(messages: messages, title: title);
      }
      return s;
    }).toList();
    emit(state.copyWith(sessions: updatedSessions));
  }

  void removeAttachment(int index) {
    final updated = List<ChatAttachment>.from(state.pendingAttachments);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      emit(state.copyWith(pendingAttachments: updated));
    }
  }

  Future<void> stopMessage() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(state.copyWith(status: ChatStatus.success));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
