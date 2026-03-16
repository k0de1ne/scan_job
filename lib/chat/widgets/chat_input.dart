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
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isTablet = MediaQuery.of(context).size.width > 600;

    final inputField = Container(
      constraints: BoxConstraints(
        maxWidth: widget.isCentered ? 800 : double.infinity,
      ),
      margin: widget.isCentered
          ? const EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.symmetric(
              horizontal: isDesktop ? 120 : (isTablet ? 48 : 16),
              vertical: 16,
            ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F20), // 30, 31, 32
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _controller,
                maxLines: null,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 16, color: Color(0xFFE3E3E3)),
                decoration: InputDecoration(
                  hintText: l10n.chatInputPlaceholder,
                  hintStyle: const TextStyle(
                    color: Color(0xFFC4C7C5),
                    fontSize: 16,
                  ), // 196, 199, 197
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
                  // Left group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Color(0xFFC4C7C5),
                        ), // 196, 199, 197
                        onPressed: () {},
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        hoverColor: const Color(0xFF3C3D3E),
                      ),
                      SizedBox(width: isTablet ? 8 : 4),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        hoverColor: const Color(0xFF3C3D3E),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tune,
                                size: 20,
                                color: Color(0xFFC4C7C5),
                              ), // 196, 199, 197
                              if (isTablet) ...[
                                const SizedBox(width: 8),
                                const Text(
                                  'Инструменты',
                                  style: TextStyle(
                                    color: Color(0xFFC4C7C5), // 196, 199, 197
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Right group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        hoverColor: const Color(0xFF3C3D3E),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isTablet)
                                const Text(
                                  'Gemini 2.0 Flash',
                                  style: TextStyle(
                                    color: Color(0xFFC4C7C5), // 196, 199, 197
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFFC4C7C5),
                              ), // 196, 199, 197
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 8 : 4),
                      if (_controller.text.isEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.mic_none,
                            color: Color(0xFFC4C7C5),
                          ), // 196, 199, 197
                          onPressed: () {}, // Changed from null to show hover
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          hoverColor: const Color(0xFF3C3D3E),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFFC4C7C5),
                          ), // 196, 199, 197
                          onPressed: _sendMessage,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          hoverColor: const Color(0xFF3C3D3E),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return inputField;
  }
}
