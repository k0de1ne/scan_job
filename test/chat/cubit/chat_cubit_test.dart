import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/repositories/chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('ChatCubit', () {
    late ChatRepository chatRepository;
    late ChatCubit chatCubit;

    final timestamp = DateTime(2024);

    setUp(() {
      chatRepository = MockChatRepository();
      chatCubit = ChatCubit(chatRepository: chatRepository);
    });

    tearDown(() async {
      await chatCubit.close();
    });

    test('initial state is ChatState', () {
      expect(chatCubit.state, const ChatState());
    });

    group('sendMessage', () {
      blocTest<ChatCubit, ChatState>(
        'does nothing when text is empty',
        build: () => chatCubit,
        act: (cubit) => cubit.sendMessage(''),
        expect: () => <ChatState>[],
        verify: (_) {
          verifyNever(
            () => chatRepository.sendMessage(
              text: any(named: 'text'),
              history: any(named: 'history'),
            ),
          );
        },
      );

      blocTest<ChatCubit, ChatState>(
        'emits loading and then success when sendMessage succeeds',
        build: () {
          when(
            () => chatRepository.sendMessage(
              text: any(named: 'text'),
              history: any(named: 'history'),
            ),
          ).thenAnswer(
            (_) => Stream.fromIterable([
              ChatMessage(
                text: 'AI response',
                role: MessageRole.ai,
                timestamp: timestamp,
              ),
            ]),
          );
          return chatCubit;
        },
        act: (cubit) => cubit.sendMessage('hello'),
        expect: () => [
          isA<ChatState>()
              .having((s) => s.status, 'status', ChatStatus.loading)
              .having((s) => s.messages.length, 'messages length', 1)
              .having((s) => s.messages[0].text, 'user message text', 'hello'),
          isA<ChatState>()
              .having((s) => s.status, 'status', ChatStatus.loading)
              .having((s) => s.messages.length, 'messages length', 2)
              .having((s) => s.messages[1].text, 'ai message text', 'AI response'),
          isA<ChatState>()
              .having((s) => s.status, 'status', ChatStatus.success)
              .having((s) => s.messages.length, 'messages length', 2),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'updates the last AI message when stream emits multiple times',
        build: () {
          when(
            () => chatRepository.sendMessage(
              text: any(named: 'text'),
              history: any(named: 'history'),
            ),
          ).thenAnswer(
            (_) => Stream.fromIterable([
              ChatMessage(
                text: 'AI thinking...',
                role: MessageRole.ai,
                timestamp: timestamp,
              ),
              ChatMessage(
                text: 'AI final answer',
                role: MessageRole.ai,
                timestamp: timestamp,
              ),
            ]),
          );
          return chatCubit;
        },
        act: (cubit) => cubit.sendMessage('hello'),
        expect: () => [
          isA<ChatState>()
              .having((s) => s.status, 'status', ChatStatus.loading)
              .having((s) => s.messages.length, 'messages length', 1),
          isA<ChatState>()
              .having((s) => s.messages.length, 'messages length', 2)
              .having((s) => s.messages[1].text, 'ai message text', 'AI thinking...'),
          isA<ChatState>()
              .having((s) => s.messages.length, 'messages length', 2)
              .having((s) => s.messages[1].text, 'ai message text', 'AI final answer'),
          isA<ChatState>()
              .having((s) => s.status, 'status', ChatStatus.success),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'emits failure when sendMessage throws',
        build: () {
          when(
            () => chatRepository.sendMessage(
              text: any(named: 'text'),
              history: any(named: 'history'),
            ),
          ).thenThrow(Exception('oops'));
          return chatCubit;
        },
        act: (cubit) => cubit.sendMessage('hello'),
        expect: () => [
          isA<ChatState>()
              .having((s) => s.status, 'status', ChatStatus.loading)
              .having((s) => s.messages.length, 'messages length', 1),
          isA<ChatState>().having((s) => s.status, 'status', ChatStatus.failure),
        ],
      );
    });

  });
}
