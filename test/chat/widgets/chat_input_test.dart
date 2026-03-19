import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/widgets/chat_input.dart';
import 'package:scan_job/theme/app_theme.dart';

import '../../helpers/pump_app.dart';

class MockChatCubit extends MockCubit<ChatState> implements ChatCubit {}

void main() {
  group('ChatInput', () {
    late ChatCubit chatCubit;

    setUp(() {
      chatCubit = MockChatCubit();
      when(() => chatCubit.state).thenReturn(const ChatState());
    });

    testWidgets('renders ChatInput', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: chatCubit,
          child: Theme(
            data: AppTheme.light,
            child: const ChatInput(),
          ),
        ),
      );
      expect(find.byType(ChatInput), findsOneWidget);
    });

    testWidgets('clears text immediately before sendMessage completes', (tester) async {
      final completer = Completer<void>();
      when(() => chatCubit.sendMessage(any())).thenAnswer((_) => completer.future);

      await tester.pumpApp(
        BlocProvider.value(
          value: chatCubit,
          child: Theme(
            data: AppTheme.light,
            child: const ChatInput(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.tap(find.byIcon(Icons.send));
      
      // Pump to trigger the _sendMessage call and its first sync parts
      await tester.pump(); 

      verify(() => chatCubit.sendMessage('hello')).called(1);
      // Text should be cleared even though sendMessage future hasn't completed
      expect(find.text('hello'), findsNothing);
      
      completer.complete();
      await tester.pump();
    });

    testWidgets('calls sendMessage when send button is tapped', (tester) async {
      when(() => chatCubit.sendMessage(any())).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: chatCubit,
          child: Theme(
            data: AppTheme.light,
            child: const ChatInput(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.tap(find.byIcon(Icons.send));

      verify(() => chatCubit.sendMessage('hello')).called(1);
      expect(find.text('hello'), findsNothing);
    });

    testWidgets('calls sendMessage when text field is submitted', (tester) async {
      when(() => chatCubit.sendMessage(any())).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: chatCubit,
          child: Theme(
            data: AppTheme.light,
            child: const ChatInput(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(() => chatCubit.sendMessage('hello')).called(1);
      expect(find.text('hello'), findsNothing);
    });

    testWidgets('does not call sendMessage when text is empty', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: chatCubit,
          child: Theme(
            data: AppTheme.light,
            child: const ChatInput(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.send));
      verifyNever(() => chatCubit.sendMessage(any()));
    });
  });
}
