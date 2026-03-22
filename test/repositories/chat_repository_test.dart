import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/repositories/chat_api_client.dart';
import 'package:scan_job/repositories/chat_repository_impl.dart';

class MockChatApiClient extends Mock implements ChatApiClient {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockChatApiClient();
    repository = ChatRepositoryImpl(apiClient: mockApiClient, deviceId: 'test_user_id');
  });

  group('ChatRepositoryImpl (Clean API Client)', () {
    test('Correctly parses <think> tags and hides them from text', () async {
      final chunks = [
        ChatStreamChunk(content: 'Hello! <think>I should be'),
        ChatStreamChunk(content: ' careful.</think> Done.'),
      ];

      when(() => mockApiClient.sendMessageStream(
        messages: any(named: 'messages'),
        userId: any(named: 'userId'),
        tools: any(named: 'tools'),
      )).thenAnswer((_) => Stream.fromIterable(chunks));

      final stream = repository.sendMessage(text: 'hi');
      final messages = await stream.toList();

      final lastMessage = messages.last;
      expect(lastMessage.text, contains('Hello!  Done.'));
      expect(lastMessage.metadata!.steps!.length, greaterThanOrEqualTo(1));
      final reasoningStep = lastMessage.metadata!.steps!.firstWhere((s) => s.title == 'thoughtStepThinkingTitle');
      expect(reasoningStep.content, equals('I should be careful.'));
    });

    test('Correctly handles parallel tool calls in a single turn', () async {
      final chunks = [
        ChatStreamChunk(
          content: '',
          toolCalls: [
            {'index': 0, 'id': 'call_1', 'function': {'name': 'test_tool', 'arguments': '{"input":"one"}'}}
          ],
        ),
        ChatStreamChunk(
          content: '',
          toolCalls: [
            {'index': 1, 'id': 'call_2', 'function': {'name': 'test_tool', 'arguments': '{"input":"two"}'}}
          ],
        ),
      ];

      var callCount = 0;
      when(() => mockApiClient.sendMessageStream(
        messages: any(named: 'messages'),
        userId: any(named: 'userId'),
        tools: any(named: 'tools'),
      )).thenAnswer((_) {
        if (callCount == 0) {
          callCount++;
          return Stream.fromIterable(chunks);
        }
        return const Stream.empty();
      });

      final stream = repository.sendMessage(text: 'call two tools');
      final messages = await stream.toList();

      final lastMessage = messages.last;
      final steps = lastMessage.metadata!.steps!;
      
      final toolSteps = steps.where((s) => s.title == 'thoughtStepToolTitle' || s.title == 'thoughtStepToolCompletedTitle').toList();
      
      // Should have 2 tool steps found by IDs or indexing
      expect(toolSteps.length, equals(2));
      expect(toolSteps.any((s) => s.tool!.contains('one')), isTrue);
      expect(toolSteps.any((s) => s.tool!.contains('two')), isTrue);
    });
  });
}
