import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/chat/widgets/code_block_builder.dart';
import 'package:scan_job/chat/widgets/thinking_process.dart';
import 'package:scan_job/theme/app_theme.dart';

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
        margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
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
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.mdLarge,
                vertical: context.spacing.md,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primaryContainer
                    : context.appColors.transparent,
                borderRadius: BorderRadius.circular(context.radius.xl),
                boxShadow: isUser ? context.shadows.small : null,
              ),
              child: MarkdownBody(
                data: message.text,
                selectable: true,
                builders: {
                  'code': CodeBlockBuilder(),
                },
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    height: 1.6,
                  ),
                  code: TextStyle(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  blockquote: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: context.spacing.xs,
                      ),
                    ),
                  ),
                  h1: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  tableBorder: TableBorder.all(
                    color: colorScheme.outlineVariant,
                  ),
                  tableBody: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  tableHead: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
