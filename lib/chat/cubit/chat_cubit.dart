import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
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

    final attachments = List<ChatAttachment>.from(state.pendingAttachments);
    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    final history = state.messages;

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
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
          if (lastAiMessage == null) {
            emit(
              state.copyWith(
                messages: [...state.messages, message],
                status: ChatStatus.loading,
              ),
            );
          } else {
            final updatedMessages = List<ChatMessage>.from(state.messages);
            updatedMessages[updatedMessages.length - 1] = message;
            emit(state.copyWith(messages: updatedMessages));
          }
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
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          error: e.toString,
        ),
      );
    }
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
