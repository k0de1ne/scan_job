import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/view/chat_view.dart';
import 'package:scan_job/repositories/chat_repository_impl.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(chatRepository: ChatRepositoryImpl()),
      child: const ChatView(),
    );
  }
}
