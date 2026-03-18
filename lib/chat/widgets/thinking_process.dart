import 'package:flutter/material.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/l10n/l10n.dart';

class ThinkingProcess extends StatefulWidget {
  const ThinkingProcess({required this.metadata, super.key});

  final ChatMetadata metadata;

  @override
  State<ThinkingProcess> createState() => _ThinkingProcessState();
}

class _ThinkingProcessState extends State<ThinkingProcess> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.chatThinkingProcess,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (widget.metadata.inputTokens != null &&
                      widget.metadata.outputTokens != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.metadata.inputTokens} ↑  ${widget.metadata.outputTokens} ↓',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.metadata.steps != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: widget.metadata.steps!
                      .map((step) => _ThoughtStepWidget(step: step))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThoughtStepWidget extends StatelessWidget {
  const _ThoughtStepWidget({required this.step});

  final ThoughtStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(colorScheme),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(colorScheme),
                        spreadRadius: 1,
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: colorScheme.outlineVariant,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (step.plan != null) ...[
                    const SizedBox(height: 12),
                    _PlanWidget(plan: step.plan!),
                  ],
                  if (step.tool != null) ...[
                    const SizedBox(height: 12),
                    _ToolCallWidget(
                      tool: step.tool!,
                      output: step.output,
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    return switch (step.status) {
      StepStatus.completed => Colors.green,
      StepStatus.active => colorScheme.primary,
      StepStatus.pending => colorScheme.outline,
    };
  }
}

class _PlanWidget extends StatelessWidget {
  const _PlanWidget({required this.plan});

  final List<PlanItem> plan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                l10n.chatPlan.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...plan.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.done ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: item.done ? Colors.green : colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: item.done
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.task,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.done
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                          decoration:
                              item.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ToolCallWidget extends StatefulWidget {
  const _ToolCallWidget({required this.tool, this.output});

  final String tool;
  final String? output;

  @override
  State<_ToolCallWidget> createState() => _ToolCallWidgetState();
}

class _ToolCallWidgetState extends State<_ToolCallWidget> {
  bool _isOutputExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: colorScheme.surfaceContainer,
            child: Row(
              children: [
                Icon(Icons.terminal, size: 14, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.tool,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.output != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.output!.length > 100)
                    InkWell(
                      onTap: () => setState(() => _isOutputExpanded = !_isOutputExpanded),
                      child: Row(
                        children: [
                          Text(
                            '${l10n.chatToolResult} (${widget.output!.length} chars)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                          Icon(
                            _isOutputExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      l10n.chatToolResult,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  if (_isOutputExpanded || widget.output!.length <= 100)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.output!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
