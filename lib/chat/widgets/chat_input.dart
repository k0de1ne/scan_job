import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/l10n/l10n.dart';

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
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: false,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            onTap: () {},
                            icon: Icons.add,
                            isIconOnly: true,
                          ),
                          const SizedBox(width: 4),
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
                          const SizedBox(width: 8),
                          _ActionButton(
                            onTap: _sendMessage,
                            icon: Icons.send,
                            isIconOnly: true,
                            backgroundColor: Colors.transparent,
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
    super.key,
    this.icon,
    this.label,
    this.isIconOnly = false,
    this.backgroundColor,
  });

  final VoidCallback onTap;
  final IconData? icon;
  final String? label;
  final bool isIconOnly;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: isIconOnly ? 0 : 12),
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
                const SizedBox(width: 8),
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
