import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/app/cubit/app_state.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/repositories/chat_repository.dart';
import 'package:scan_job/repositories/chat_repository_impl.dart';
import 'package:scan_job/router/app_router.dart';
import 'package:scan_job/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(),
        ),
      ],
      child: BlocProvider(
        create: (_) => AppCubit(),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
