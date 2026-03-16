import 'package:equatable/equatable.dart';

enum MessageRole {
  user,
  ai,
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });

  final String text;
  final MessageRole role;
  final DateTime timestamp;

  @override
  List<Object> get props => [text, role, timestamp];
}
