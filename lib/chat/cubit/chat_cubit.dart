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

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);

    emit(
      state.copyWith(
        messages: updatedMessages,
        status: ChatStatus.loading,
      ),
    );

    final response = await _chatRepository.sendMessage(text);
    final aiMessage = ChatMessage(
      text: response,
      role: MessageRole.ai,
      timestamp: DateTime.now(),
    );

    final finalMessages = List<ChatMessage>.from(state.messages)
      ..add(aiMessage);
    emit(
      state.copyWith(
        messages: finalMessages,
        status: ChatStatus.success,
      ),
    );
  }
}
