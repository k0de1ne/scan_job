import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/widgets/chat_message_bubble.dart';
import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime.now();

  group('ChatMessageBubble Markdown Tests', () {
    testWidgets('renders simple text correctly', (tester) async {
      final message = ChatMessage(
        text: 'Hello world',
        role: MessageRole.ai,
        timestamp: now,
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('renders inline code without CodeBlockBuilder', (tester) async {
      final message = ChatMessage(
        text: 'Try `inline code` here',
        role: MessageRole.ai,
        timestamp: now,
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      // MarkdownBody handles inline code, but it shouldn't use our custom builder
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('Copy'), findsNothing); // Custom builder has "Copy"
    });

    testWidgets('renders code block with CodeBlockBuilder', (tester) async {
      final message = ChatMessage(
        text: '```dart\nvoid main() {}\n```',
        role: MessageRole.ai,
        timestamp: now,
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MarkdownBody), findsOneWidget);
      // Our CodeBlockBuilder adds a "Copy" button
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('void main() {}'), findsOneWidget);
    });

    testWidgets('handles complex markdown without crashing', (tester) async {
      final message = ChatMessage(
        text: '''
# Header
* List item 1
* List item 2

| Table | Head |
|-------|------|
| Cell  | Data |

`inline` and 
```
block
```
''',
        role: MessageRole.ai,
        timestamp: now,
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MarkdownBody), findsOneWidget);
    });

    testWidgets('handles multiple code blocks', (tester) async {
      final message = ChatMessage(
        text: '''
First block:
```js
console.log(1);
```
Second block:
```python
print(2)
```
''',
        role: MessageRole.ai,
        timestamp: now,
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsNWidgets(2));
      expect(find.text('console.log(1);'), findsOneWidget);
      expect(find.text('print(2)'), findsOneWidget);
    });

    testWidgets('handles empty code blocks', (tester) async {
      final message = ChatMessage(
        text: 'Empty block:\n```\n\n```',
        role: MessageRole.ai,
        timestamp: now,
      );

      await tester.pumpApp(
        Scaffold(
          body: ChatMessageBubble(message: message),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Copy'), findsOneWidget);
    });
  });
}
