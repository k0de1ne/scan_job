import 'package:bloc/bloc.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/repositories/chat_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatState());

  final ChatRepository _chatRepository;

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

      await for (final message in stream) {
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
      }

      emit(state.copyWith(status: ChatStatus.success));
    } on Exception catch (_) {
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }

  void clearChat() {
    emit(const ChatState());
  }
}
