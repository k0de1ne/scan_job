import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/chat/widgets/code_block_builder.dart';

import '../../helpers/helpers.dart';

void main() {
  group('CodeBlockBuilder', () {
    testWidgets('renders code block correctly', (tester) async {
      const markdown = '''
```dart
void main() {
  print('hello');
}
```
''';

      await tester.pumpApp(
        Scaffold(
          body: MarkdownBody(
            data: markdown,
            builders: {
              'code': CodeBlockBuilder(),
            },
          ),
        ),
      );

      expect(find.text('Code'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text("void main() {\n  print('hello');\n}"), findsOneWidget);
    });

    testWidgets('does not render as block for inline code', (tester) async {
      const markdown = 'Here is some `inline code`.';

      await tester.pumpApp(
        Scaffold(
          body: MarkdownBody(
            data: markdown,
            builders: {
              'code': CodeBlockBuilder(),
            },
          ),
        ),
      );

      expect(find.text('Code'), findsNothing);
      expect(find.textContaining('inline code'), findsOneWidget);
    });

    testWidgets('copies code to clipboard', (tester) async {
      const code = "print('hello');";
      const markdown = '```\n$code\n```';

      final methodCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (message) async {
        if (message.method == 'Clipboard.setData') {
          methodCalls.add(message);
        }
        return null;
      });

      await tester.pumpApp(
        Scaffold(
          body: MarkdownBody(
            data: markdown,
            builders: {
              'code': CodeBlockBuilder(),
            },
          ),
        ),
      );

      await tester.tap(find.text('Copy'));
      await tester.pump(); // Start animation/state change

      expect(methodCalls.length, 1);
      expect(
        (methodCalls.first.arguments as Map<dynamic, dynamic>)['text'],
        code,
      );
      expect(find.text('Copied'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Wait for the status to revert
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(); // Trigger rebuild after delay
      
      expect(find.text('Copy'), findsOneWidget);
    });
  });
}
