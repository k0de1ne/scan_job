import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/widgets/settings_dialog.dart';

class ChatSidebar extends StatelessWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surfaceContainerLow,
      width: 280,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SideButton(
                icon: Icons.menu,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 12),
              _SideButton(
                icon: Icons.edit_square,
                label: l10n.chatNewChat,
                onTap: () {
                  context.read<ChatCubit>().clearChat();
                  Navigator.of(context).maybePop();
                },
              ),
              const Spacer(),
              _SideButton(
                icon: Icons.settings_outlined,
                label: l10n.chatNavSettings,
                onTap: () {
                  Navigator.of(context).maybePop();
                  SettingsDialog.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.onTap,
    super.key,
    this.icon,
    this.label,
  });

  final VoidCallback onTap;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
              if (label != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
