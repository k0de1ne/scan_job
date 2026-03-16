import 'package:flutter/material.dart';
import 'package:scan_job/chat/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: isUser
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            : const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1E1F20) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFFE3E3E3),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
