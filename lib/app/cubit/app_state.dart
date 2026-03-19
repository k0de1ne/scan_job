import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppState extends Equatable {
  const AppState({
    this.themeMode = ThemeMode.system,
    this.llmBaseUrl = 'http://localhost:1234/v1',
    this.llmApiKey = 'not-needed',
    this.llmModelName = 'openai/gpt-oss-20b',
  });

  final ThemeMode themeMode;
  final String llmBaseUrl;
  final String llmApiKey;
  final String llmModelName;

  @override
  List<Object> get props => [themeMode, llmBaseUrl, llmApiKey, llmModelName];

  AppState copyWith({
    ThemeMode? themeMode,
    String? llmBaseUrl,
    String? llmApiKey,
    String? llmModelName,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      llmBaseUrl: llmBaseUrl ?? this.llmBaseUrl,
      llmApiKey: llmApiKey ?? this.llmApiKey,
      llmModelName: llmModelName ?? this.llmModelName,
    );
  }
}
