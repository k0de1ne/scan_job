import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/widgets/chat_message_bubble.dart';
import 'package:scan_job/chat/widgets/thinking_process.dart';
import 'package:scan_job/theme/app_theme.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ChatMessageBubble', () {
    testWidgets('renders user message correctly', (tester) async {
      final message = ChatMessage(
        text: 'Hello AI',
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      expect(find.text('Hello AI'), findsOneWidget);
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);

      // Verify it uses primaryContainer for user message
      final markdown = find.byType(MarkdownBody);
      final container = tester.widget<Container>(
        find.ancestor(of: markdown, matching: find.byType(Container)).first,
      );
      
      final theme = Theme.of(tester.element(find.byType(ChatMessageBubble)));
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, theme.colorScheme.primaryContainer);
    });

    testWidgets('renders AI message correctly', (tester) async {
      final message = ChatMessage(
        text: 'Hello User',
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      expect(find.text('Hello User'), findsOneWidget);
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);

      final markdown = find.byType(MarkdownBody);
      final container = tester.widget<Container>(
        find.ancestor(of: markdown, matching: find.byType(Container)).first,
      );
      
      final decoration = container.decoration! as BoxDecoration;
      // Should be transparent
      final theme = Theme.of(tester.element(find.byType(ChatMessageBubble)));
      final appColors = theme.extension<AppColors>()!;
      expect(decoration.color, appColors.transparent);
    });

    testWidgets('renders AI message with thinking process', (tester) async {
      final message = ChatMessage(
        text: 'AI response',
        role: MessageRole.ai,
        timestamp: DateTime.now(),
        metadata: const ChatMetadata(
          steps: [
            ThoughtStep(
              title: 'Thinking',
              content: 'Analyzing...',
              status: StepStatus.completed,
            ),
          ],
        ),
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      expect(find.byType(ThinkingProcess), findsOneWidget);
      expect(find.text('AI response'), findsOneWidget);
    });
  });
}
