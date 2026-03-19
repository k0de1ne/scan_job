import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/widgets/thinking_process.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ThinkingProcess', () {
    const metadata = ChatMetadata(
      inputTokens: 100,
      outputTokens: 200,
      steps: [
        ThoughtStep(
          title: 'thoughtStepThinkingTitle',
          content: 'thoughtStepThinkingSubTitle',
          status: StepStatus.active,
          tool: 'search_web',
          output: 'Search results from the web...',
          plan: [
            PlanItem(task: 'Task 1', done: true),
            PlanItem(task: 'Task 2'),
          ],
        ),
        ThoughtStep(
          title: 'Custom Title',
          content: 'Custom Content',
        ),
      ],
    );

    testWidgets('renders collapsed state correctly', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThinkingProcess(metadata: metadata),
        ),
      );

      expect(find.text('Thinking'), findsOneWidget);
      expect(find.text('100 ↑  200 ↓'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.text('Thinking'), findsNWidgets(1)); // Only header initially
    });

    testWidgets('expands when tapped', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThinkingProcess(metadata: metadata),
        ),
      );

      await tester.tap(find.text('Thinking'));
      await tester.pumpAndSettle();

      expect(find.text('Thinking'), findsNWidgets(2)); // Header + Step Title
      expect(find.text('Analysis'), findsOneWidget); // Step Content (for thoughtStepThinkingSubTitle)
      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom Content'), findsOneWidget);
    });

    testWidgets('shows plan items in expanded state', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ThinkingProcess(metadata: metadata),
        ),
      );

      await tester.tap(find.text('Thinking'));
      await tester.pumpAndSettle();

      expect(find.text('ACTION PLAN'), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      
      // Check for checkmark icon for Task 1
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows tool calls and expands output', (tester) async {
      final largeOutput = 'A' * 101;
      final metadataWithLargeOutput = ChatMetadata(
        steps: [
          ThoughtStep(
            title: 'Tool Use',
            content: 'Using a tool',
            status: StepStatus.active,
            tool: 'long_tool',
            output: largeOutput,
          ),
        ],
      );

      await tester.pumpApp(
        Scaffold(
          body: ThinkingProcess(metadata: metadataWithLargeOutput),
        ),
      );

      await tester.tap(find.text('Thinking'));
      await tester.pumpAndSettle();

      expect(find.text('long_tool'), findsOneWidget);
      expect(find.textContaining('Result (101 chars)'), findsOneWidget);
      expect(find.text(largeOutput), findsNothing); // Collapsed by default

      await tester.tap(find.textContaining('Result'));
      await tester.pumpAndSettle();

      expect(find.text(largeOutput), findsOneWidget);
    });

    testWidgets('shows small tool output without expansion', (tester) async {
      const smallOutput = 'Small output';
      const metadataWithSmallOutput = ChatMetadata(
        steps: [
          ThoughtStep(
            title: 'Tool Use',
            content: 'Using a tool',
            status: StepStatus.active,
            tool: 'short_tool',
            output: smallOutput,
          ),
        ],
      );

      await tester.pumpApp(
        const Scaffold(
          body: ThinkingProcess(metadata: metadataWithSmallOutput),
        ),
      );

      await tester.tap(find.text('Thinking'));
      await tester.pumpAndSettle();

      expect(find.text('short_tool'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);
      expect(find.text(smallOutput), findsOneWidget);
    });
  });
}
