import 'dart:async';

import 'package:scan_job/chat/models/chat_message.dart' as model;
import 'package:scan_job/repositories/chat_api_client.dart';
import 'package:scan_job/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    String? baseUrl,
    String? apiKey,
    String? modelName,
    ChatApiClient? apiClient,
  }) {
    if (apiClient != null) {
      _apiClient = apiClient;
      _modelName = modelName;
    } else {
      _updateConfig(
        baseUrl: baseUrl,
        apiKey: apiKey,
        modelName: modelName,
      );
    }
  }

  late ChatApiClient _apiClient;
  String? _baseUrl;
  String? _apiKey;
  String? _modelName;

  void _updateConfig({
    String? baseUrl,
    String? apiKey,
    String? modelName,
  }) {
    _baseUrl = baseUrl ?? _baseUrl ?? 'http://localhost:1234/v1';
    _apiKey = apiKey ?? _apiKey ?? 'not-needed';
    _modelName = modelName ?? _modelName ?? 'openai/gpt-oss-20b';

    _apiClient = ChatApiClient(
      baseUrl: _baseUrl!,
      apiKey: _apiKey!,
      modelName: _modelName!,
    );
  }

  @override
  void updateConfig({
    String? baseUrl,
    String? apiKey,
    String? modelName,
  }) {
    _updateConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      modelName: modelName,
    );
  }

  @override
  Stream<model.ChatMessage> sendMessage({
    required String text,
    List<model.ChatMessage> history = const [],
  }) async* {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system', 
        'content': 'You are Scan Job, a professional AI assistant. '
            'You have the capability to call multiple tools PARALLEL (simultaneously) in a single response. '
            'If a task requires multiple checks, call ALL necessary tools at once in a single message without waiting for each individual result.'
      },
      ...history.map((m) => {
        'role': m.role == model.MessageRole.user ? 'user' : 'assistant',
        'content': m.text,
      }),
      {'role': 'user', 'content': text},
    ];

    final steps = <model.ThoughtStep>[
      const model.ThoughtStep(
        title: 'thoughtStepAnalysisTitle',
        content: 'thoughtStepAnalysisContent',
        status: model.StepStatus.active,
      ),
    ];

    final responseBuffer = StringBuffer();
    
    for (var iteration = 0; iteration < 10; iteration++) {
      final stream = _apiClient.sendMessageStream(
        messages: messages,
        tools: [
          {
            'type': 'function',
            'function': {
              'name': 'test_tool',
              'description': 'Diagnostic tool.',
              'parameters': {
                'type': 'object',
                'properties': {'input': {'type': 'string'}},
                'required': ['input'],
              },
            },
          }
        ],
      );

      final thoughtBuffer = StringBuffer();
      final toolCallBuffers = <int, Map<String, dynamic>>{};
      var hasNewToolCall = false;
      var currentReasoningIdx = -1;
      var isInsideThinkTag = false;

      await for (final chunk in stream) {
        // 1. Native Reasoning from API
        if (chunk.reasoning != null && chunk.reasoning!.isNotEmpty) {
          thoughtBuffer.write(chunk.reasoning);
          if (steps.length == 1) {
            steps[0] = const model.ThoughtStep(
              title: 'thoughtStepAnalysisTitle',
              content: 'thoughtStepAnalysisContent',
              status: model.StepStatus.completed,
            );
          }
          if (currentReasoningIdx == -1) {
            steps.add(model.ThoughtStep(
              title: iteration == 0 ? 'thoughtStepThinkingTitle' : 'thoughtStepThinkingSubTitle',
              content: '',
              status: model.StepStatus.active,
            ));
            currentReasoningIdx = steps.length - 1;
          }
          steps[currentReasoningIdx] = model.ThoughtStep(
            title: steps[currentReasoningIdx].title,
            content: thoughtBuffer.toString().trim(),
            status: model.StepStatus.active,
          );
        }

        // 2. Native Tool Calls from API
        if (chunk.toolCalls != null) {
          hasNewToolCall = true;
          for (final delta in chunk.toolCalls!) {
            final idx = delta['index'] as int? ?? 0;
            final buffer = toolCallBuffers.putIfAbsent(idx, () => {'id': '', 'name': '', 'args': StringBuffer()});
            if (delta['id'] != null) buffer['id'] = delta['id'] as String;
            final function = delta['function'] as Map<String, dynamic>?;
            if (function != null) {
              if (function['name'] != null) {
                buffer['name'] = function['name'] as String;
              }
              if (function['arguments'] != null) {
                (buffer['args'] as StringBuffer).write(function['arguments'] as String);
              }
            }
            
            final tName = buffer['name'] as String;
            final tArgs = buffer['args'].toString();
            final stepKey = 'tool_${iteration}_$idx';
            final sIdx = steps.indexWhere((s) => s.tool != null && s.tool!.startsWith('[$stepKey]'));
            
            if (sIdx == -1) {
              steps.add(model.ThoughtStep(
                title: 'thoughtStepToolTitle',
                content: 'thoughtStepToolStarting',
                tool: '[$stepKey] $tName($tArgs)',
                status: model.StepStatus.active,
              ));
            } else {
              steps[sIdx] = model.ThoughtStep(
                title: steps[sIdx].title,
                content: 'thoughtStepToolRunning',
                tool: '[$stepKey] $tName($tArgs)',
                status: model.StepStatus.active,
              );
            }
          }
        }

        // 3. Main Content & <think> tags
        if (chunk.content.isNotEmpty) {
          var remainingContent = chunk.content;

          while (remainingContent.isNotEmpty) {
            if (!isInsideThinkTag) {
              if (remainingContent.contains('<think>')) {
                final parts = remainingContent.split('<think>');
                if (parts[0].isNotEmpty) responseBuffer.write(parts[0]);
                isInsideThinkTag = true;
                remainingContent = parts.sublist(1).join('<think>');
                
                // Ensure reasoning step exists
                if (currentReasoningIdx == -1) {
                  steps.add(model.ThoughtStep(
                    title: iteration == 0 ? 'thoughtStepThinkingTitle' : 'thoughtStepThinkingSubTitle',
                    content: '',
                    status: model.StepStatus.active,
                  ));
                  currentReasoningIdx = steps.length - 1;
                }
              } else {
                responseBuffer.write(remainingContent);
                remainingContent = '';
              }
            } else {
              if (remainingContent.contains('</think>')) {
                final parts = remainingContent.split('</think>');
                thoughtBuffer.write(parts[0]);
                isInsideThinkTag = false;
                remainingContent = parts.sublist(1).join('</think>');
                
                if (currentReasoningIdx != -1) {
                  steps[currentReasoningIdx] = model.ThoughtStep(
                    title: steps[currentReasoningIdx].title,
                    content: thoughtBuffer.toString().trim(),
                    status: model.StepStatus.active,
                  );
                }
              } else {
                thoughtBuffer.write(remainingContent);
                remainingContent = '';
                
                if (currentReasoningIdx != -1) {
                  steps[currentReasoningIdx] = model.ThoughtStep(
                    title: steps[currentReasoningIdx].title,
                    content: thoughtBuffer.toString().trim(),
                    status: model.StepStatus.active,
                  );
                }
              }
            }
          }
        }

        yield model.ChatMessage(
          text: responseBuffer.toString(),
          role: model.MessageRole.ai,
          timestamp: DateTime.now(),
          metadata: model.ChatMetadata(steps: List.from(steps)),
        );
      }

      if (currentReasoningIdx != -1) {
        steps[currentReasoningIdx] = model.ThoughtStep(title: steps[currentReasoningIdx].title, content: steps[currentReasoningIdx].content, status: model.StepStatus.completed);
      }

      if (!hasNewToolCall) break;

      // Finalize tool calls and build history for next turn
      final assistantCalls = <Map<String, dynamic>>[];
      for (final idx in toolCallBuffers.keys) {
        final b = toolCallBuffers[idx]!;
        final res = '{"status": "success", "data": "Result for ${b['args']}"}';
        final key = 'tool_${iteration}_$idx';
        final sIdx = steps.indexWhere((s) => s.tool != null && s.tool!.startsWith('[$key]'));
        if (sIdx != -1) {
          steps[sIdx] = model.ThoughtStep(
            title: 'thoughtStepToolCompletedTitle',
            content: 'thoughtStepToolDone',
            tool: steps[sIdx].tool,
            output: res,
            status: model.StepStatus.completed,
          );
        }
        assistantCalls.add({
          'id': b['id'], 
          'type': 'function', 
          'function': {
            'name': b['name'], 
            'arguments': b['args'].toString(),
          },
        });
        messages.add({
          'role': 'tool', 
          'tool_call_id': b['id'], 
          'name': b['name'], 
          'content': res,
        });
      }
      messages.add({'role': 'assistant', 'content': null, 'tool_calls': assistantCalls});
    }

    // Ensure all steps are closed
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].status == model.StepStatus.active) {
        steps[i] = model.ThoughtStep(
          title: steps[i].title, 
          content: steps[i].content.isEmpty ? 'thoughtStepToolDone' : steps[i].content, 
          status: model.StepStatus.completed, 
          tool: steps[i].tool, 
          output: steps[i].output,
        );
      }
    }
    yield model.ChatMessage(
      text: responseBuffer.toString(), 
      role: model.MessageRole.ai, 
      timestamp: DateTime.now(), 
      metadata: model.ChatMetadata(steps: List.from(steps)),
    );
  }
}
