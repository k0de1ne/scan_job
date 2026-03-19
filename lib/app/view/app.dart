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
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) => false, // Only build once
        builder: (context, state) {
          return RepositoryProvider<ChatRepository>(
            create: (context) => ChatRepositoryImpl(
              baseUrl: state.llmBaseUrl,
              apiKey: state.llmApiKey,
              modelName: state.llmModelName,
            ),
            child: const AppView(),
          );
        },
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) =>
          previous.llmBaseUrl != current.llmBaseUrl ||
          previous.llmApiKey != current.llmApiKey ||
          previous.llmModelName != current.llmModelName,
      listener: (context, state) {
        context.read<ChatRepository>().updateConfig(
          baseUrl: state.llmBaseUrl,
          apiKey: state.llmApiKey,
          modelName: state.llmModelName,
        );
      },
      child: BlocBuilder<AppCubit, AppState>(
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
      ),
    );
  }
}
