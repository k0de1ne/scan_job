import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppState extends Equatable {
  const AppState({
    this.themeMode = ThemeMode.system,
    this.llmBaseUrl = const String.fromEnvironment('LLM_BASE_URL', defaultValue: 'http://10.0.2.2:8000/v1'),
    this.llmApiKey = const String.fromEnvironment('LLM_API_KEY', defaultValue: 'proxy-guest-key'),
    this.llmModelName = const String.fromEnvironment('LLM_MODEL_NAME', defaultValue: 'gpt-3.5-turbo'),
    this.deviceId = '',
    this.inputPricePerMillion = 0.0,
    this.outputPricePerMillion = 0.0,
  });

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? ThemeMode.system.index],
      llmBaseUrl: json['llmBaseUrl'] as String? ?? const String.fromEnvironment('LLM_BASE_URL', defaultValue: 'http://10.0.2.2:8000/v1'),
      llmApiKey: json['llmApiKey'] as String? ?? const String.fromEnvironment('LLM_API_KEY', defaultValue: 'proxy-guest-key'),
      llmModelName: json['llmModelName'] as String? ?? const String.fromEnvironment('LLM_MODEL_NAME', defaultValue: 'gpt-3.5-turbo'),
      deviceId: json['deviceId'] as String? ?? '',
      inputPricePerMillion: (json['inputPricePerMillion'] as num? ?? 0.0).toDouble(),
      outputPricePerMillion: (json['outputPricePerMillion'] as num? ?? 0.0).toDouble(),
    );
  }

  final ThemeMode themeMode;
  final String llmBaseUrl;
  final String llmApiKey;
  final String llmModelName;
  final String deviceId;
  final double inputPricePerMillion;
  final double outputPricePerMillion;

  @override
  List<Object> get props => [
        themeMode,
        llmBaseUrl,
        llmApiKey,
        llmModelName,
        deviceId,
        inputPricePerMillion,
        outputPricePerMillion,
      ];

  AppState copyWith({
    ThemeMode? themeMode,
    String? llmBaseUrl,
    String? llmApiKey,
    String? llmModelName,
    String? deviceId,
    double? inputPricePerMillion,
    double? outputPricePerMillion,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      llmBaseUrl: llmBaseUrl ?? this.llmBaseUrl,
      llmApiKey: llmApiKey ?? this.llmApiKey,
      llmModelName: llmModelName ?? this.llmModelName,
      deviceId: deviceId ?? this.deviceId,
      inputPricePerMillion:
          inputPricePerMillion ?? this.inputPricePerMillion,
      outputPricePerMillion:
          outputPricePerMillion ?? this.outputPricePerMillion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'llmBaseUrl': llmBaseUrl,
      'llmApiKey': llmApiKey,
      'llmModelName': llmModelName,
      'deviceId': deviceId,
      'inputPricePerMillion': inputPricePerMillion,
      'outputPricePerMillion': outputPricePerMillion,
    };
  }
}
