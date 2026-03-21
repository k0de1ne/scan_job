import 'dart:convert';
import 'dart:io';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

void main() async {
  final chatModel = ChatOpenAI(
    apiKey: 'not-needed',
    baseUrl: 'http://localhost:1234/v1',
    defaultOptions: const ChatOpenAIOptions(
      model: 'openai/gpt-oss-20b',
      temperature: 0,
    ),
  );

  final prompt = PromptValue.chat([
    ChatMessage.system('Think before answering.'),
    ChatMessage.humanText('1+1'),
  ]);

  stdout.writeln('Starting stream...');
  final stream = chatModel.stream(prompt);

  await for (final chunk in stream) {
    stdout
      ..writeln('--- Chunk ---')
      ..writeln('Content: ${chunk.output.content}')
      ..writeln('Metadata: ${jsonEncode(chunk.metadata)}');
  }
  stdout.writeln('Stream finished.');
}
