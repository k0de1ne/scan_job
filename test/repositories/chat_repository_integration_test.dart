import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/repositories/chat_repository_impl.dart';

void main() {
  late ChatRepositoryImpl repository;

  setUp(() {
    repository = ChatRepositoryImpl(
      baseUrl: 'http://localhost:1234/v1',
      modelName: 'openai/gpt-oss-20b',
    );
  });

  group('ChatRepository (Integration with LM Studio)', () {
    test('Real LLM response contains reasoning and final answer', () async {
      final stream = repository.sendMessage(
        text: 'What is 1+1? Please show your reasoning process.',
      );

      final messages = await stream.toList();
      expect(messages, isNotEmpty);

      final lastMessage = messages.last;
      
      final steps = lastMessage.metadata?.steps ?? [];
      final hasReasoning = steps.any((s) => s.title.contains('Размышление') && s.content.isNotEmpty);
      
      expect(lastMessage.text, contains('2'));
      expect(hasReasoning, isTrue, reason: 'LLM should have provided some reasoning steps');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('Real LLM triggers parallel test_tool calls', () async {
      final stream = repository.sendMessage(
        text: 'Call test_tool twice at the same time: once with "request_A" and once with "request_B". Do not wait between calls.',
      );

      final messages = await stream.toList();
      final lastMessage = messages.last;
      
      final steps = lastMessage.metadata?.steps ?? [];
      
      // Filter tool steps (either "Вызов инструмента" or "Инструмент ... выполнен")
      final toolSteps = steps.where((s) => s.tool != null && s.tool!.contains('test_tool')).toList();
      
      expect(toolSteps.length, greaterThanOrEqualTo(2), reason: 'LLM should have triggered at least 2 tool calls');
      
      final hasA = toolSteps.any((s) => s.tool!.contains('request_A'));
      final hasB = toolSteps.any((s) => s.tool!.contains('request_B'));
      
      expect(hasA, isTrue, reason: 'Should find tool call for request_A');
      expect(hasB, isTrue, reason: 'Should find tool call for request_B');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
