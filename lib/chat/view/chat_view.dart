import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/chat_state.dart';
import 'package:scan_job/chat/widgets/chat_input.dart';
import 'package:scan_job/chat/widgets/chat_message_bubble.dart';
import 'package:scan_job/chat/widgets/sidebar.dart';
import 'package:scan_job/l10n/l10n.dart';

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
      body: Row(
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
                          horizontal: screenWidth > 900 ? 120 : 20,
                          vertical: 32,
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
    final l10n = context.l10n;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: isExpanded ? 280 : 68,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: [
          _SideButton(
            icon: Icons.menu,
            onTap: onToggle,
          ),
          const SizedBox(height: 12),
          _SideButton(
            icon: Icons.edit_square,
            label: isExpanded ? l10n.chatNewChat : null,
            onTap: () => context.read<ChatCubit>().clearChat(),
          ),
          const Spacer(),
          _SideButton(
            icon: Icons.settings_outlined,
            label: isExpanded ? l10n.chatNavSettings : null,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    this.label,
    required this.onTap,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

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
              Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
              ClipRect(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: label != null ? 1 : 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    width: label != null ? 180 : 0,
                    child: label != null
                        ? Row(
                            children: [
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
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ChatInput(),
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            l10n.chatInputFooter,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9AA0A6),
            ),
          ),
        ),
      ],
    );
  }
}
