import 'package:bloc/bloc.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/repositories/chat_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository chatRepository})
    : super(const ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        status: ChatStatus.loading,
      ),
    );

    // Simulated response with metadata matching the HTML reference
    await Future<void>.delayed(const Duration(milliseconds: 600));
    
    final aiMessage = ChatMessage(
      text: 'Я провел анализ и выполнил необходимые действия.',
      role: MessageRole.ai,
      timestamp: DateTime.now(),
      metadata: const ChatMetadata(
        inputTokens: 1240,
        outputTokens: 450,
        steps: [
          ThoughtStep(
            status: StepStatus.completed,
            title: 'Планирование',
            content: 'Формирую шаги реализации.',
            plan: [
              PlanItem(task: 'Поиск в базе', done: true),
              PlanItem(task: 'Обновление данных', done: false),
            ],
          ),
          ThoughtStep(
            status: StepStatus.completed,
            title: 'Вызов инструмента',
            content: 'Ищу информацию...',
            tool: 'grep_search({ pattern: "api_key" })',
            output: 'Found 1 match in .env',
          ),
          ThoughtStep(
            status: StepStatus.active,
            title: 'Sub-agent',
            content: 'Делегирую задачу специалисту...',
            tool: 'codebase_investigator(...)',
            output: '> Исследование начато...\n> Найдено 3 зависимости.',
          ),
        ],
      ),
    );

    emit(
      state.copyWith(
        messages: [...state.messages, aiMessage],
        status: ChatStatus.success,
      ),
    );
  }

  void clearChat() {
    emit(const ChatState());
  }
}
