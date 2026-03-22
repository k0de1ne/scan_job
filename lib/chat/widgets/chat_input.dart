import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({this.isCentered = false, super.key});

  final bool isCentered;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (result != null && mounted) {
        final cubit = context.read<ChatCubit>();
        for (final file in result.files) {
          if (file.bytes != null) {
            await cubit.addAttachment(
              ChatAttachment(
                name: file.name,
                bytes: file.bytes!,
                extension: file.extension,
              ),
            );
          }
        }
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;
    final cubit = context.read<ChatCubit>();
    if (text.isNotEmpty || cubit.state.pendingAttachments.isNotEmpty) {
      if (cubit.state.status == ChatStatus.loading) return;

      _controller.clear();
      setState(() {});
      await cubit.sendMessage(text);
    }
  }

  void _stopMessage() {
    unawaited(context.read<ChatCubit>().stopMessage());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.spacing.mdLarge),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(context.radius.xxl),
            boxShadow: context.shadows.medium,
          ),
          child: Material(
            color: context.appColors.transparent,
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final isLoading = state.status == ChatStatus.loading;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.pendingAttachments.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.spacing.xl,
                          context.spacing.md,
                          context.spacing.xl,
                          0,
                        ),
                        child: Wrap(
                          spacing: context.spacing.sm,
                          runSpacing: context.spacing.sm,
                          children: List.generate(
                            state.pendingAttachments.length,
                            (index) {
                              final attachment = state.pendingAttachments[index];
                              return _AttachmentChip(
                                attachment: attachment,
                                onRemove: () =>
                                    context.read<ChatCubit>().removeAttachment(index),
                              );
                            },
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.xl,
                        vertical: context.spacing.sm,
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        enabled: !isLoading,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.chatInputPlaceholder,
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: context.spacing.md,
                          ),
                          filled: false,
                        ),
                        onSubmitted: (_) {
                          unawaited(_sendMessage());
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.spacing.lg,
                        0,
                        context.spacing.lg,
                        context.spacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ActionButton(
                                onTap: isLoading ? null : () => unawaited(_pickFile()),
                                icon: Icons.add,
                                isIconOnly: true,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                _ActionButton(
                                  onTap: _stopMessage,
                                  icon: Icons.stop,
                                  isIconOnly: true,
                                )
                              else
                                _ActionButton(
                                  onTap: (state.pendingAttachments.isEmpty &&
                                          _controller.text.isEmpty)
                                      ? null
                                      : () => unawaited(_sendMessage()),
                                  icon: Icons.send,
                                  isIconOnly: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
  });

  final ChatAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForExtension(attachment.extension),
            size: 16,
            color: colorScheme.primary,
          ),
          SizedBox(width: context.spacing.xs),
          Flexible(
            child: Text(
              attachment.name,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: context.spacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: colorScheme.onSurfaceVariant,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.onTap,
    this.icon,
    this.label,
    this.isIconOnly = false,
  });

  final VoidCallback? onTap;
  final IconData? icon;
  final String? label;
  final bool isIconOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: context.appColors.transparent,
      borderRadius: BorderRadius.circular(context.radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.sm),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(
            horizontal: isIconOnly ? 0 : context.spacing.md,
          ),
          width: isIconOnly ? 40 : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: context.spacing.sm),
              ],
              if (icon != null)
                Icon(
                  icon,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
