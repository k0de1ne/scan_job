import 'package:flutter/material.dart';
import 'package:scan_job/chat/widgets/sidebar_content.dart';
import 'package:scan_job/theme/app_theme.dart';

class ChatSidebar extends StatelessWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: const SidebarContent(),
        ),
      ),
    );
  }
}
