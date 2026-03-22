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

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
        task: json['task'] as String,
        done: json['done'] as bool? ?? false,
      );

  final String task;
  final bool done;

  @override
  List<Object> get props => [task, done];

  Map<String, dynamic> toJson() => {
        'task': task,
        'done': done,
      };
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

  factory ThoughtStep.fromJson(Map<String, dynamic> json) => ThoughtStep(
        title: json['title'] as String,
        content: json['content'] as String,
        status: StepStatus.values[json['status'] as int? ?? StepStatus.pending.index],
        plan: (json['plan'] as List<dynamic>?)
            ?.map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        tool: json['tool'] as String?,
        output: json['output'] as String?,
      );

  final String title;
  final String content;
  final StepStatus status;
  final List<PlanItem>? plan;
  final String? tool;
  final String? output;

  @override
  List<Object?> get props => [title, content, status, plan, tool, output];

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'status': status.index,
        'plan': plan?.map((e) => e.toJson()).toList(),
        'tool': tool,
        'output': output,
      };
}

class ChatMetadata extends Equatable {
  const ChatMetadata({
    this.steps,
    this.inputTokens,
    this.outputTokens,
  });

  factory ChatMetadata.fromJson(Map<String, dynamic> json) => ChatMetadata(
        steps: (json['steps'] as List<dynamic>?)
            ?.map((e) => ThoughtStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        inputTokens: json['inputTokens'] as int?,
        outputTokens: json['outputTokens'] as int?,
      );

  final List<ThoughtStep>? steps;
  final int? inputTokens;
  final int? outputTokens;

  @override
  List<Object?> get props => [steps, inputTokens, outputTokens];

  Map<String, dynamic> toJson() => {
        'steps': steps?.map((e) => e.toJson()).toList(),
        'inputTokens': inputTokens,
        'outputTokens': outputTokens,
      };
}

class ChatAttachment extends Equatable {
  const ChatAttachment({
    required this.name,
    required this.bytes,
    this.extension,
    this.extractedText,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) => ChatAttachment(
        name: json['name'] as String,
        bytes: (json['bytes'] as List<dynamic>).cast<int>(),
        extension: json['extension'] as String?,
        extractedText: json['extractedText'] as String?,
      );

  final String name;
  final List<int> bytes;
  final String? extension;
  final String? extractedText;

  @override
  List<Object?> get props => [name, bytes, extension, extractedText];

  Map<String, dynamic> toJson() => {
        'name': name,
        'bytes': bytes,
        'extension': extension,
        'extractedText': extractedText,
      };
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.metadata,
    this.attachments,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String,
        role: MessageRole.values[json['role'] as int],
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: json['metadata'] != null
            ? ChatMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
            : null,
        attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => ChatAttachment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final ChatMetadata? metadata;
  final List<ChatAttachment>? attachments;

  @override
  List<Object?> get props => [text, role, timestamp, metadata, attachments];

  Map<String, dynamic> toJson() => {
        'text': text,
        'role': role.index,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata?.toJson(),
        'attachments': attachments?.map((e) => e.toJson()).toList(),
      };
}
