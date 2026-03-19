import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/app/cubit/app_state.dart';
import 'package:scan_job/chat/models/chat_message.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';

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

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final inputCost = (widget.metadata.inputTokens ?? 0) *
            (appState.inputPricePerMillion / 1000000);
        final outputCost = (widget.metadata.outputTokens ?? 0) *
            (appState.outputPricePerMillion / 1000000);
        final totalCost = inputCost + outputCost;
        final hasPricing = appState.inputPricePerMillion > 0 ||
            appState.outputPricePerMillion > 0;

        return Container(
          margin: EdgeInsets.only(bottom: context.spacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(context.radius.xl),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
            boxShadow: _isExpanded ? context.shadows.medium : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(context.radius.xl),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.mdLarge,
                    vertical: context.spacing.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: context.spacing.md),
                      Text(
                        l10n.chatThinkingProcess,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (widget.metadata.inputTokens != null ||
                          widget.metadata.outputTokens != null) ...[
                        SizedBox(width: context.spacing.lg),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.metadata.inputTokens != null)
                              Padding(
                                padding:
                                    EdgeInsets.only(right: context.spacing.sm),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.spacing.sm,
                                    vertical: context.spacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(
                                        context.radius.sm),
                                  ),
                                  child: Text(
                                    '${widget.metadata.inputTokens} ↑',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.metadata.outputTokens != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.sm,
                                  vertical: context.spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(context.radius.sm),
                                ),
                                child: Text(
                                  '${widget.metadata.outputTokens} ↓',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            if (hasPricing && totalCost > 0) ...[
                              SizedBox(width: context.spacing.md),
                              Text(
                                '\$${totalCost.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: context.appColors.success,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      SizedBox(width: context.spacing.sm),
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
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.sm,
                    0,
                    context.spacing.sm,
                    context.spacing.sm,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(context.radius.sm),
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
      },
    );
  }
}

class _ThoughtStepWidget extends StatelessWidget {
  const _ThoughtStepWidget({required this.step});

  final ThoughtStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.md,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: context.spacing.md),
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(top: context.spacing.xs + 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(colorScheme, appColors),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(colorScheme, appColors),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: colorScheme.outlineVariant,
                    margin: EdgeInsets.symmetric(vertical: context.spacing.xs),
                  ),
                ),
              ],
            ),
            SizedBox(width: context.spacing.lg),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translate(context, step.title),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  Text(
                    _translate(context, step.content),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (step.plan != null) ...[
                    SizedBox(height: context.spacing.md),
                    _PlanWidget(plan: step.plan!),
                  ],
                  if (step.tool != null) ...[
                    SizedBox(height: context.spacing.md),
                    _ToolCallWidget(
                      tool: step.tool!,
                      output: step.output,
                    ),
                  ],
                  SizedBox(height: context.spacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme, AppColors appColors) {
    return switch (step.status) {
      StepStatus.completed => appColors.success,
      StepStatus.active => colorScheme.primary,
      StepStatus.pending => colorScheme.outline,
    };
  }

  String _translate(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'thoughtStepThinkingTitle' => l10n.thoughtStepThinkingTitle,
      'thoughtStepThinkingSubTitle' => l10n.thoughtStepThinkingSubTitle,
      'thoughtStepToolTitle' => l10n.thoughtStepToolTitle(1), // Default index
      'thoughtStepToolStarting' => l10n.thoughtStepToolStarting,
      'thoughtStepToolCompletedTitle' => l10n.thoughtStepToolCompletedTitle(1),
      'thoughtStepToolDone' => l10n.thoughtStepToolDone,
      'thoughtStepToolRunning' => l10n.thoughtStepToolRunning,
      _ => key,
    };
  }
}

class _PlanWidget extends StatelessWidget {
  const _PlanWidget({required this.plan});

  final List<PlanItem> plan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.radius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 14, color: colorScheme.onSurfaceVariant),
              SizedBox(width: context.spacing.sm),
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
          SizedBox(height: context.spacing.md),
          ...plan.map((item) => Padding(
                padding: EdgeInsets.only(bottom: context.spacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.done
                            ? appColors.success
                            : appColors.transparent,
                        border: Border.all(
                          color: item.done
                              ? appColors.success
                              : colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: item.done
                          ? Icon(Icons.check,
                              size: 14, color: appColors.onSuccess)
                          : null,
                    ),
                    SizedBox(width: context.spacing.md),
                    Flexible(
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
    final appColors = context.appColors;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.md,
              vertical: context.spacing.sm,
            ),
            color: colorScheme.surfaceContainer,
            child: Row(
              children: [
                Icon(Icons.terminal, size: 14, color: colorScheme.primary),
                SizedBox(width: context.spacing.sm),
                Flexible(
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
              padding: EdgeInsets.all(context.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.output!.length > 100)
                    InkWell(
                      onTap: () => setState(
                          () => _isOutputExpanded = !_isOutputExpanded),
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
                            _isOutputExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
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
                      padding: EdgeInsets.only(top: context.spacing.sm),
                      child: Text(
                        widget.output!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: appColors.success,
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
