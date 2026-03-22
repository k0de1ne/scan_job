import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/widgets/chat_input.dart';
import 'package:scan_job/chat/widgets/chat_message_bubble.dart';
import 'package:scan_job/chat/widgets/sidebar.dart';
import 'package:scan_job/chat/widgets/sidebar_content.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';
import 'package:scan_job/widgets/settings_dialog.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool _isSidebarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: isMobile ? const ChatSidebar() : null,
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.status != ChatStatus.failure &&
            current.status == ChatStatus.failure,
        listener: (context, state) {
          if (state.status == ChatStatus.failure && state.error != null) {
            final error = state.error!;
            String message;
            String? subtitle;
            bool isLimitError = false;

            if (error == 'LIMIT_REACHED') {
              message = l10n.chatErrorLimitReached;
              subtitle = l10n.chatErrorLimitReachedSubtitle;
              isLimitError = true;
            } else if (error.contains('401') || error.contains('Unauthorized')) {
              message = l10n.chatErrorNoApiKey;
            } else if (error.contains('429') ||
                error.contains('Too Many Requests') ||
                error.contains('API Error') ||
                error.contains('Connection refused') ||
                error.contains('SocketException') ||
                error.contains('HttpException')) {
              message = l10n.chatErrorServerBusy;
            } else {
              message = l10n.chatErrorGeneric;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
                backgroundColor:
                    isLimitError ? colorScheme.secondary : colorScheme.error,
                duration:
                    isLimitError ? const Duration(seconds: 10) : const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: isLimitError ? l10n.chatNavSettings : 'OK',
                  textColor: isLimitError
                      ? colorScheme.onSecondary
                      : colorScheme.onError,
                  onPressed: () {
                    if (isLimitError) {
                      SettingsDialog.show(context);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  },
                ),
              ),
            );
          }
        },
        child: Row(
          children: [
            if (!isMobile)
              _DesktopSidebar(
                isExpanded: _isSidebarExpanded,
                onToggle: () =>
                    setState(() => _isSidebarExpanded = !_isSidebarExpanded),
              ),
            Expanded(
              child: Column(
                children: [
                  _Header(
                    isMobile: isMobile,
                    title: l10n.appTitle,
                  ),
                  Expanded(
                    child: BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        if (state.messages.isEmpty) {
                          return _HeroSection(l10n: l10n);
                        }
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 900
                                ? 120
                                : context.spacing.mdLarge,
                            vertical: context.spacing.xxl,
                          ),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            return ChatMessageBubble(
                              message: state.messages[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _InputArea(l10n: l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: isExpanded ? 280 : 68,
      color: colorScheme.surfaceContainerLow,
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.lg,
      ),
      child: SidebarContent(
        isExpanded: isExpanded,
        onMenuTap: onToggle,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isMobile,
    required this.title,
  });

  final bool isMobile;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Text(
            title,
            style: GoogleFonts.googleSans(
              fontSize: 22,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.mdLarge,
          vertical: 80,
        ),
        child: Column(
          children: [
            Text(
              l10n.chatInputHero,
              style: GoogleFonts.googleSans(
                fontSize: 44,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  const _InputArea({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ChatInput(),
        Padding(
          padding: EdgeInsets.only(
            bottom: context.spacing.md,
            top: context.spacing.sm,
          ),
          child: Text(
            l10n.chatInputFooter,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
