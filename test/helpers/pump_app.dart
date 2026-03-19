import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';

class MockChatCubit extends Mock implements ChatCubit {}
class MockAppCubit extends Mock implements AppCubit {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget, {ChatCubit? chatCubit, AppCubit? appCubit}) {
    var current = widget;
    
    final providers = <BlocProvider>[];
    if (chatCubit != null) {
      providers.add(BlocProvider<ChatCubit>.value(value: chatCubit));
    }
    if (appCubit != null) {
      providers.add(BlocProvider<AppCubit>.value(value: appCubit));
    }

    if (providers.isNotEmpty) {
      current = MultiBlocProvider(
        providers: providers,
        child: current,
      );
    }

    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: current,
      ),
    );
  }
}
