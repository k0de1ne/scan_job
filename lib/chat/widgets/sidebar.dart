import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';
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
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SideButton(
                icon: Icons.menu,
                onTap: () async => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              _SideButton(
                icon: Icons.settings_outlined,
                label: l10n.chatNavSettings,
                onTap: () async {
                  await Navigator.of(context).maybePop();
                  if (!context.mounted) return;
                  await SettingsDialog.show(context);
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
      color: context.appColors.transparent,
      borderRadius: BorderRadius.circular(context.radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.sm),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.sm),
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
              if (label != null) ...[
                SizedBox(width: context.spacing.md),
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
