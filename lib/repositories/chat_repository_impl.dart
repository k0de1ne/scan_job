import 'package:scan_job/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl();

  @override
  Future<String> sendMessage(String message) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'This is a simulated AI response to: "$message"';
  }
}
