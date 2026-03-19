import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  final HttpClient _client = HttpClient();

  Stream<ChatStreamChunk> sendMessageStream({
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async* {
    final uri = Uri.parse('$baseUrl/chat/completions');
    final request = await _client.postUrl(uri);
    
    request.headers.contentType = ContentType.json;
    if (apiKey != 'not-needed') {
      request.headers.set('Authorization', 'Bearer $apiKey');
    }

    final body = {
      'model': modelName,
      'messages': messages,
      'stream': true,
      'temperature': 0,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
    };

    request.write(jsonEncode(body));
    final response = await request.close();

    if (response.statusCode != 200) {
      final errorBody = await response.transform(utf8.decoder).join();
      throw Exception('API Error: ${response.statusCode} - $errorBody');
    }

    int? promptTokens;
    int? completionTokens;

    await for (final line in response
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.isEmpty) continue;
      if (!line.startsWith('data: ')) continue;
      
      final dataStr = line.substring(6).trim();
      if (dataStr == '[DONE]') break;

      try {
        final data = jsonDecode(dataStr) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        final choice = choices[0] as Map<String, dynamic>;
        final delta = choice['delta'] as Map<String, dynamic>;
        
        final usage = data['usage'] as Map<String, dynamic>?;
        if (usage != null) {
          promptTokens = usage['prompt_tokens'] as int? ?? promptTokens;
          completionTokens = usage['completion_tokens'] as int? ?? completionTokens;
        }

        final content = delta['content'] as String? ?? '';
        final reasoning = (delta['reasoning_content'] as String?) ?? 
                          (delta['reasoning'] as String?);
        
        // Handle tool_calls delta
        List<Map<String, dynamic>>? toolCalls;
        if (delta['tool_calls'] != null) {
          toolCalls = (delta['tool_calls'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        }

        if (content.isNotEmpty || reasoning != null || toolCalls != null) {
          yield ChatStreamChunk(
            content: content,
            reasoning: reasoning,
            toolCalls: toolCalls,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
          );
        }
      } on Exception catch (_) {
        // Ignore malformed chunks
      }
    }
  }
}
