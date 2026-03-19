import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/app/cubit/app_cubit.dart';
import 'package:scan_job/app/cubit/app_state.dart';

void main() {
  group('AppCubit', () {
    test('initial state is AppState', () {
      expect(AppCubit().state, const AppState());
    });

    blocTest<AppCubit, AppState>(
      'setThemeMode emits state with new themeMode',
      build: AppCubit.new,
      act: (cubit) => cubit.setThemeMode(ThemeMode.light),
      expect: () => [const AppState(themeMode: ThemeMode.light)],
    );

    blocTest<AppCubit, AppState>(
      'setLlmBaseUrl emits state with new llmBaseUrl',
      build: AppCubit.new,
      act: (cubit) => cubit.setLlmBaseUrl('https://api.example.com'),
      expect: () => [const AppState(llmBaseUrl: 'https://api.example.com')],
    );

    blocTest<AppCubit, AppState>(
      'setLlmApiKey emits state with new llmApiKey',
      build: AppCubit.new,
      act: (cubit) => cubit.setLlmApiKey('secret-key'),
      expect: () => [const AppState(llmApiKey: 'secret-key')],
    );

    blocTest<AppCubit, AppState>(
      'setLlmModelName emits state with new llmModelName',
      build: AppCubit.new,
      act: (cubit) => cubit.setLlmModelName('llama3'),
      expect: () => [const AppState(llmModelName: 'llama3')],
    );
  });

  group('AppState', () {
    test('supports value equality', () {
      expect(const AppState(), const AppState());
    });

    test('props are correct', () {
      expect(
        const AppState(
          themeMode: ThemeMode.dark,
          llmBaseUrl: 'url',
          llmApiKey: 'key',
          llmModelName: 'model',
        ).props,
        [ThemeMode.dark, 'url', 'key', 'model'],
      );
    });

    test('copyWith returns object with updated values', () {
      expect(
        const AppState().copyWith(
          themeMode: ThemeMode.light,
          llmBaseUrl: 'new-url',
          llmApiKey: 'new-key',
          llmModelName: 'new-model',
        ),
        const AppState(
          themeMode: ThemeMode.light,
          llmBaseUrl: 'new-url',
          llmApiKey: 'new-key',
          llmModelName: 'new-model',
        ),
      );
    });
  });
}
