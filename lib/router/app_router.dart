import 'package:go_router/go_router.dart';
import 'package:scan_job/chat/view/chat_page.dart';
import 'package:scan_job/home/view/home_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatPage(),
      ),
    ],
  );
}
