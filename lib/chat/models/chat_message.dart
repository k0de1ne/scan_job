import 'package:equatable/equatable.dart';

enum MessageRole {
  user,
  ai,
}

enum StepStatus {
  completed,
  active,
  pending,
}

class PlanItem extends Equatable {
  const PlanItem({
    required this.task,
    this.done = false,
  });

  final String task;
  final bool done;

  @override
  List<Object> get props => [task, done];
}

class ThoughtStep extends Equatable {
  const ThoughtStep({
    required this.title,
    required this.content,
    this.status = StepStatus.pending,
    this.plan,
    this.tool,
    this.output,
  });

  final String title;
  final String content;
  final StepStatus status;
  final List<PlanItem>? plan;
  final String? tool;
  final String? output;

  @override
  List<Object?> get props => [title, content, status, plan, tool, output];
}

class ChatMetadata extends Equatable {
  const ChatMetadata({
    this.steps,
    this.inputTokens,
    this.outputTokens,
  });

  final List<ThoughtStep>? steps;
  final int? inputTokens;
  final int? outputTokens;

  @override
  List<Object?> get props => [steps, inputTokens, outputTokens];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.metadata,
  });

  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final ChatMetadata? metadata;

  @override
  List<Object?> get props => [text, role, timestamp, metadata];
}
