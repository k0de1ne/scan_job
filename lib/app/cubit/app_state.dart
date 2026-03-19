import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppState extends Equatable {
  const AppState({
    this.themeMode = ThemeMode.system,
    this.llmBaseUrl = 'http://192.168.0.17:1234/v1',
    this.llmApiKey = 'not-needed',
    this.llmModelName = 'openai/gpt-oss-20b',
    this.inputPricePerMillion = 0.0,
    this.outputPricePerMillion = 0.0,
  });

  final ThemeMode themeMode;
  final String llmBaseUrl;
  final String llmApiKey;
  final String llmModelName;
  final double inputPricePerMillion;
  final double outputPricePerMillion;

  @override
  List<Object> get props => [
        themeMode,
        llmBaseUrl,
        llmApiKey,
        llmModelName,
        inputPricePerMillion,
        outputPricePerMillion,
      ];

  AppState copyWith({
    ThemeMode? themeMode,
    String? llmBaseUrl,
    String? llmApiKey,
    String? llmModelName,
    double? inputPricePerMillion,
    double? outputPricePerMillion,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      llmBaseUrl: llmBaseUrl ?? this.llmBaseUrl,
      llmApiKey: llmApiKey ?? this.llmApiKey,
      llmModelName: llmModelName ?? this.llmModelName,
      inputPricePerMillion:
          inputPricePerMillion ?? this.inputPricePerMillion,
      outputPricePerMillion:
          outputPricePerMillion ?? this.outputPricePerMillion,
    );
  }
}
