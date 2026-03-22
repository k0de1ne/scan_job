import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/widgets/connected_accounts.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';
import 'package:scan_job/widgets/settings_dialog.dart';

class SidebarContent extends StatelessWidget {
  const SidebarContent({
    super.key,
    this.isExpanded = true,
    this.onMenuTap,
  });

  final bool isExpanded;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SideButton(
              icon: Icons.menu,
              onTap: onMenuTap ?? () => unawaited(Navigator.of(context).maybePop()),
              isExpanded: isExpanded,
            ),
            if (isExpanded) ...[
              const Spacer(),
              _SideButton(
                icon: Icons.edit_calendar_outlined,
                onTap: () {
                  context.read<ChatCubit>().createNewChat();
                  if (onMenuTap == null) {
                    unawaited(Navigator.of(context).maybePop());
                  }
                },
              ),
            ],
          ],
        ),
        if (isExpanded) ...[
          SizedBox(height: context.spacing.lg),
          _SearchField(),
          SizedBox(height: context.spacing.lg),
          Expanded(
            child: _ChatList(),
          ),
        ] else
          const Spacer(),
        if (isExpanded) ...[
          SizedBox(height: context.spacing.md),
          const ConnectedAccounts(),
        ],
        SizedBox(height: context.spacing.md),
        const Divider(height: 1),
        SizedBox(height: context.spacing.md),
        _SideButton(
          icon: Icons.settings_outlined,
          label: isExpanded ? l10n.chatNavSettings : null,
          onTap: () async {
            if (onMenuTap == null) {
              await Navigator.of(context).maybePop();
            }
            if (!context.mounted) return;
            await SettingsDialog.show(context);
          },
          isExpanded: isExpanded,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: (value) => context.read<ChatCubit>().setSearchQuery(value),
      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.chatSidebarSearchPlaceholder,
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withAlpha(128),
        ),
        prefixIcon: Icon(
          Icons.search,
          size: 18,
          color: colorScheme.onSurfaceVariant.withAlpha(128),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius.sm),
          borderSide: BorderSide.none,
        ),
        isDense: true,
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final sessions = state.filteredSessions;

        if (sessions.isEmpty && state.searchQuery.isNotEmpty) {
          return Center(
            child: Text(
              l10n.chatSidebarEmptySearch,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final isActive = session.id == state.activeSessionId;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SideButton(
                label: session.title,
                isActive: isActive,
                onTap: () {
                  context.read<ChatCubit>().selectChat(session.id);
                },
                onDelete: () => context.read<ChatCubit>().deleteChat(session.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.onTap,
    this.icon,
    this.label,
    this.isActive = false,
    this.isExpanded = true,
    this.onDelete,
  });

  final VoidCallback onTap;
  final IconData? icon;
  final String? label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isActive ? colorScheme.surfaceContainer : Colors.transparent,
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
                Icon(
                  icon,
                  color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              if (isExpanded && label != null) ...[
                if (icon != null) SizedBox(width: context.spacing.md),
                Expanded(
                  child: Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onDelete != null && isActive)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    color: colorScheme.error.withAlpha(128),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
