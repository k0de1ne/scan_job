import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:langchain_tiktoken/langchain_tiktoken.dart';

class ChatStreamChunk {
  ChatStreamChunk({
    required this.content,
    this.reasoning,
    this.toolCalls,
    this.promptTokens,
    this.completionTokens,
  });
  final String content;
  final String? reasoning;
  final List<Map<String, dynamic>>? toolCalls;
  final int? promptTokens;
  final int? completionTokens;
}

class ChatApiClient {
  ChatApiClient({
    required this.baseUrl,
    required this.apiKey,
    required this.modelName,
  });
  final String baseUrl;
  final String apiKey;
  final String modelName;
  final http.Client _client = http.Client();

  Stream<ChatStreamChunk> sendMessageStream({
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async* {
    final uri = Uri.parse('$baseUrl/chat/completions');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKey != 'not-needed') {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final body = {
      'model': modelName,
      'messages': messages,
      'stream': true,
      'stream_options': {'include_usage': true},
      'temperature': 0,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
    };

    final request = http.Request('POST', uri);
    request.headers.addAll(headers);
    request.body = jsonEncode(body);

    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      final bodyStr = await streamedResponse.stream.bytesToString();
      throw Exception('API Error: ${streamedResponse.statusCode} - $bodyStr');
    }

    // Initialize Tiktoken encoding
    final encoding = getEncoding('cl100k_base');
    
    int? promptTokens;
    int? completionTokens;
    
    // Accurate local prompt token count
    int totalPromptTokens = 0;
    for (final m in messages) {
      final content = m['content'] as String? ?? '';
      totalPromptTokens += encoding.encode(content).length;
      totalPromptTokens += 4; // Add standard metadata tokens for messages
    }
    promptTokens = totalPromptTokens;

    String buffer = '';
    int accurateCompletionTokens = 0;

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      buffer += chunk;

      while (buffer.contains('\n')) {
        final newlineIndex = buffer.indexOf('\n');
        var line = buffer.substring(0, newlineIndex).trim();
        buffer = buffer.substring(newlineIndex + 1);

        if (line.isEmpty || !line.startsWith('data: ')) continue;
        if (line == 'data: [DONE]') continue;

        final dataStr = line.substring(6);
        try {
          final data = jsonDecode(dataStr) as Map<String, dynamic>;
          
          final usage = data['usage'] as Map<String, dynamic>?;
          if (usage != null) {
            promptTokens = usage['prompt_tokens'] as int? ?? promptTokens;
            completionTokens =
                usage['completion_tokens'] as int? ?? completionTokens;
          }

          final choices = data['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) {
            if (usage != null || promptTokens != null) {
              yield ChatStreamChunk(
                content: '',
                promptTokens: promptTokens,
                completionTokens: completionTokens ?? accurateCompletionTokens,
              );
            }
            continue;
          }

          final choice = choices[0] as Map<String, dynamic>;
          final delta = choice['delta'] as Map<String, dynamic>?;
          if (delta == null) {
             if (usage != null || promptTokens != null) {
                yield ChatStreamChunk(
                  content: '',
                  promptTokens: promptTokens,
                  completionTokens: completionTokens ?? accurateCompletionTokens,
                );
             }
             continue;
          }

          final content = delta['content'] as String? ?? '';
          final reasoning =
              (delta['reasoning_content'] as String?) ??
              (delta['reasoning'] as String?);

          // Update tokens using Tiktoken
          if (content.isNotEmpty) {
            accurateCompletionTokens += encoding.encode(content).length;
          }
          if (reasoning != null && reasoning.isNotEmpty) {
            accurateCompletionTokens += encoding.encode(reasoning).length;
          }

          List<Map<String, dynamic>>? toolCalls;
          if (delta['tool_calls'] != null) {
            toolCalls = (delta['tool_calls'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            accurateCompletionTokens += 8; // Tool calls overhead
          }

          if (content.isNotEmpty || reasoning != null || toolCalls != null || usage != null) {
            yield ChatStreamChunk(
              content: content,
              reasoning: reasoning,
              toolCalls: toolCalls,
              promptTokens: promptTokens,
              completionTokens: completionTokens ?? accurateCompletionTokens,
            );
          }
        } catch (e) {
          // Ignore malformed
        }
      }
    }
  }
}
