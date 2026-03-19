import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  final request = await client.postUrl(
    Uri.parse('http://192.168.0.17:1234/v1/chat/completions'),
  );
  
  request.headers.contentType = ContentType.json;
  
  final body = {
    'model': 'openai/gpt-oss-20b',
    'messages': [
      {'role': 'user', 'content': '1+1. Think step-by-step.'}
    ],
    'stream': true,
  };
  
  request.write(jsonEncode(body));
  final response = await request.close();
  
  response
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.startsWith('data: ')) {
      final dataStr = line.substring(6);
      if (dataStr == '[DONE]') return;
      
      try {
        final data = jsonDecode(dataStr) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        final choice = choices[0] as Map<String, dynamic>;
        final delta = choice['delta'] as Map<String, dynamic>;
        
        if (delta.containsKey('reasoning')) {
          stdout.write('[[REASONING: ${delta['reasoning']}]]');
        }
        if (delta.containsKey('content')) {
          stdout.write(delta['content'] as String);
        }
      } on Exception catch (_) {
        // Ignore malformed chunks
      }
    }
  });
}
