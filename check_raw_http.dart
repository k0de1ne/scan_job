import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://192.168.0.17:1234/v1';
  final modelName = 'openai/gpt-oss-20b';

  print('--- LM Studio Diagnostic ---');
  print('Connecting to: $baseUrl');
  print('Model: $modelName');

  final uri = Uri.parse('$baseUrl/chat/completions');
  final request = http.Request('POST', uri);
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'model': modelName,
    'messages': [{'role': 'user', 'content': 'Say hi'}],
    'stream': true,
    'stream_options': {'include_usage': true},
  });

  try {
    final client = http.Client();
    final streamedResponse = await client.send(request);
    print('Status Code: ${streamedResponse.statusCode}');

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        print('CHUNK: $line');
        
        if (line.startsWith('data: ')) {
          final dataStr = line.substring(6).trim();
          if (dataStr == '[DONE]') continue;
          try {
            final data = jsonDecode(dataStr);
            if (data['usage'] != null) {
              print('>>> FOUND USAGE: ${data['usage']}');
            }
          } catch (_) {}
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
