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
            if (message.attachments != null && message.attachments!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: context.spacing.sm),
                child: Wrap(
                  spacing: context.spacing.sm,
                  runSpacing: context.spacing.sm,
                  alignment: isUser ? WrapAlignment.end : WrapAlignment.start,
                  children: message.attachments!.map((attachment) {
                    return _AttachmentPreview(attachment: attachment);
                  }).toList(),
                ),
              ),
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

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.radius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForExtension(attachment.extension),
            size: 20,
            color: colorScheme.primary,
          ),
          SizedBox(width: context.spacing.sm),
          Flexible(
            child: Text(
              attachment.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForExtension(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
