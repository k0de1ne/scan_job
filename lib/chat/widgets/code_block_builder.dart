import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final textContent = element.textContent;
    
    // Check if it's a block-level code.
    // In markdown package, code blocks are often wrapped in <pre><code>...</code></pre>
    // but the builder might be called for both.
    // A robust way to detect a block code is checking for:
    // 1. Newlines in content
    // 2. Class attribute (usually for language highlighting)
    // 3. If it's the only child of a 'pre' element (though we only see 'code' here)
    
    final isCodeBlock = textContent.contains('\n') || 
                       element.attributes.containsKey('class') ||
                       // Handle empty code blocks which might not have newlines
                       (element.generatedId == null && textContent.isEmpty);

    if (!isCodeBlock) {
      return null; // Use default rendering for inline code
    }

    return _CodeBlockWidget(textContent: textContent);
  }
}

class _CodeBlockWidget extends StatefulWidget {
  const _CodeBlockWidget({required this.textContent});

  final String textContent;

  @override
  State<_CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<_CodeBlockWidget> {
  bool _isCopied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.textContent.trim()));
    if (!mounted) return;
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.md,
              vertical: context.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.radius.sm),
                topRight: Radius.circular(context.radius.sm),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.codeTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                InkWell(
                  onTap: _copyToClipboard,
                  borderRadius: BorderRadius.circular(context.radius.xs),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.xs,
                      vertical: context.spacing.xs / 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 14,
                          color: _isCopied
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: context.spacing.xs),
                        Text(
                          _isCopied
                              ? context.l10n.codeCopied
                              : context.l10n.codeCopy,
                          style: TextStyle(
                            fontSize: 12,
                            color: _isCopied
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.spacing.lg),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                widget.textContent.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
