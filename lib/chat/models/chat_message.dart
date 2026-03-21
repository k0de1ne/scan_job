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

class ChatAttachment extends Equatable {
  const ChatAttachment({
    required this.name,
    required this.bytes,
    this.extension,
    this.extractedText,
  });

  final String name;
  final List<int> bytes;
  final String? extension;
  final String? extractedText;

  @override
  List<Object?> get props => [name, bytes, extension, extractedText];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.metadata,
    this.attachments,
  });

  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final ChatMetadata? metadata;
  final List<ChatAttachment>? attachments;

  @override
  List<Object?> get props => [text, role, timestamp, metadata, attachments];
}
