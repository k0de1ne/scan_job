import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/app/cubit/app_state.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/widgets/sidebar.dart';
import 'package:scan_job/widgets/settings_dialog.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ChatSidebar', () {
    late MockChatCubit chatCubit;
    late MockAppCubit appCubit;

    setUp(() {
      chatCubit = MockChatCubit();
      when(() => chatCubit.state).thenReturn(const ChatState());
      when(() => chatCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => chatCubit.clearChat()).thenAnswer((_) async {});

      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
      when(() => appCubit.stream).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          drawer: ChatSidebar(),
        ),
        appCubit: appCubit,
        chatCubit: chatCubit,
      );

      // Open drawer
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(ChatSidebar), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.edit_square), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('calls clearChat when new chat is tapped', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          drawer: ChatSidebar(),
        ),
        chatCubit: chatCubit,
      );

      // Open drawer
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_square));
      await tester.pumpAndSettle();

      verify(() => chatCubit.clearChat()).called(1);
      expect(find.byType(ChatSidebar), findsNothing); // Should be closed
    });

    testWidgets('opens SettingsDialog when settings is tapped', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          drawer: ChatSidebar(),
        ),
        appCubit: appCubit,
        chatCubit: chatCubit,
      );

      // Open drawer
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsOneWidget);
      expect(find.byType(ChatSidebar), findsNothing); // Should be closed
    });

    testWidgets('closes drawer when menu icon is tapped', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          drawer: ChatSidebar(),
        ),
        appCubit: appCubit,
        chatCubit: chatCubit,
      );

      // Open drawer
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(ChatSidebar), findsNothing);
    });
  });
}
