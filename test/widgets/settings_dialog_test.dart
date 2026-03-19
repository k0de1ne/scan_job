import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/app/cubit/app_state.dart';
import 'package:scan_job/widgets/settings_dialog.dart';

import '../helpers/pump_app.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('SettingsDialog', () {
    late AppCubit appCubit;

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
    });

    testWidgets('renders SettingsDialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      
      await tester.pumpApp(
        BlocProvider.value(
          value: appCubit,
          child: const SettingsDialog(),
        ),
      );
      expect(find.byType(SettingsDialog), findsOneWidget);
    });

    testWidgets('calls setThemeMode when theme option is tapped', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpApp(
        BlocProvider.value(
          value: appCubit,
          child: const SettingsDialog(),
        ),
      );

      await tester.tap(find.text('Light')); 
      await tester.pumpAndSettle();
      verify(() => appCubit.setThemeMode(ThemeMode.light)).called(1);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      verify(() => appCubit.setThemeMode(ThemeMode.dark)).called(1);

      await tester.tap(find.text('System Default'));
      await tester.pumpAndSettle();
      verify(() => appCubit.setThemeMode(ThemeMode.system)).called(1);
    });

    testWidgets('calls setLlmBaseUrl when base url is changed', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpApp(
        BlocProvider.value(
          value: appCubit,
          child: const SettingsDialog(),
        ),
      );

      final textField = find.byType(TextField).at(0);
      await tester.enterText(textField, 'http://new-url');
      verify(() => appCubit.setLlmBaseUrl('http://new-url')).called(1);
    });

    testWidgets('calls setLlmApiKey when api key is changed', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpApp(
        BlocProvider.value(
          value: appCubit,
          child: const SettingsDialog(),
        ),
      );

      final textField = find.byType(TextField).at(1);
      await tester.enterText(textField, 'new-key');
      verify(() => appCubit.setLlmApiKey('new-key')).called(1);
    });

    testWidgets('calls setLlmModelName when model name is changed', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpApp(
        BlocProvider.value(
          value: appCubit,
          child: const SettingsDialog(),
        ),
      );

      final textField = find.byType(TextField).at(2);
      await tester.enterText(textField, 'new-model');
      verify(() => appCubit.setLlmModelName('new-model')).called(1);
    });

    testWidgets('closes dialog when close button is tapped', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpApp(
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => BlocProvider.value(
              value: appCubit,
              child: const SettingsDialog(),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsDialog), findsNothing);
    });
  });
}
