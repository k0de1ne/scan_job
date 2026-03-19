import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_job/app/cubit/app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void setThemeMode(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
  }

  void setLlmBaseUrl(String baseUrl) {
    emit(state.copyWith(llmBaseUrl: baseUrl));
  }

  void setLlmApiKey(String apiKey) {
    emit(state.copyWith(llmApiKey: apiKey));
  }

  void setLlmModelName(String modelName) {
    emit(state.copyWith(llmModelName: modelName));
  }
}
