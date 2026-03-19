import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
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

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isNotEmpty) {
      await context.read<ChatCubit>().sendMessage(text);
      _controller.clear();
      setState(() {});
    }
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl,
                    vertical: context.spacing.sm,
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.chatInputPlaceholder,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: context.spacing.md),
                      filled: false,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.lg,
                    0,
                    context.spacing.lg,
                    context.spacing.md,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: context.spacing.sm,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            onTap: () {},
                            icon: Icons.add,
                            isIconOnly: true,
                          ),
                          SizedBox(width: context.spacing.xs),
                          _ActionButton(
                            onTap: () {},
                            icon: Icons.tune,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            onTap: () {},
                            label: l10n.chatModelQuick,
                            icon: Icons.expand_more,
                          ),
                          SizedBox(width: context.spacing.sm),
                          _ActionButton(
                            onTap: _sendMessage,
                            icon: Icons.send,
                            isIconOnly: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onTap,
    this.icon,
    this.label,
    this.isIconOnly = false,
  });

  final VoidCallback onTap;
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
