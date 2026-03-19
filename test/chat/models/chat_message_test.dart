import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/chat/models/chat_message.dart';

void main() {
  group('PlanItem', () {
    test('supports value equality', () {
      expect(
        const PlanItem(task: 'task'),
        const PlanItem(task: 'task'),
      );
    });

    test('props are correct', () {
      expect(
        const PlanItem(task: 'task', done: true).props,
        ['task', true],
      );
    });
  });

  group('ThoughtStep', () {
    test('supports value equality', () {
      expect(
        const ThoughtStep(title: 'title', content: 'content'),
        const ThoughtStep(title: 'title', content: 'content'),
      );
    });

    test('props are correct', () {
      const plan = [PlanItem(task: 'task')];
      expect(
        const ThoughtStep(
          title: 'title',
          content: 'content',
          status: StepStatus.completed,
          plan: plan,
          tool: 'tool',
          output: 'output',
        ).props,
        ['title', 'content', StepStatus.completed, plan, 'tool', 'output'],
      );
    });
  });

  group('ChatMetadata', () {
    test('supports value equality', () {
      expect(
        const ChatMetadata(),
        const ChatMetadata(),
      );
    });

    test('props are correct', () {
      const steps = [ThoughtStep(title: 'title', content: 'content')];
      expect(
        const ChatMetadata(
          steps: steps,
          inputTokens: 1,
          outputTokens: 2,
        ).props,
        [steps, 1, 2],
      );
    });
  });

  group('ChatMessage', () {
    final timestamp = DateTime(2024);

    test('supports value equality', () {
      expect(
        ChatMessage(text: 'text', role: MessageRole.user, timestamp: timestamp),
        ChatMessage(text: 'text', role: MessageRole.user, timestamp: timestamp),
      );
    });

    test('props are correct', () {
      const metadata = ChatMetadata();
      expect(
        ChatMessage(
          text: 'text',
          role: MessageRole.ai,
          timestamp: timestamp,
          metadata: metadata,
        ).props,
        ['text', MessageRole.ai, timestamp, metadata],
      );
    });
  });
}
