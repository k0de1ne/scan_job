import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/repositories/chat_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatState());

  final ChatRepository _chatRepository;
  StreamSubscription<ChatMessage>? _subscription;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final history = state.messages;

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        status: ChatStatus.loading,
      ),
    );

    try {
      final stream = _chatRepository.sendMessage(
        text: text,
        history: history,
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
          emit(state.copyWith(status: ChatStatus.failure));
        },
        onDone: () {
          emit(state.copyWith(status: ChatStatus.success));
        },
        cancelOnError: true,
      );
    } on Exception catch (_) {
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  Future<void> stopMessage() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(state.copyWith(status: ChatStatus.success));
  }

  Future<void> clearChat() async {
    await _subscription?.cancel();
    emit(const ChatState());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
