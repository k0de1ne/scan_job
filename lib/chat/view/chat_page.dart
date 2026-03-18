import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/view/chat_view.dart';
import 'package:scan_job/repositories/chat_repository.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        chatRepository: context.read<ChatRepository>(),
      ),
      child: const ChatView(),
    );
  }
}
