import 'package:flutter/material.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/widgets/thinking_process.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser && message.metadata != null)
              ThinkingProcess(metadata: message.metadata!),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFFD4E4FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ]
                    : null,
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
