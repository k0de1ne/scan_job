import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.blackWhite,
    surface: const Color(0xFFF0F4F9),
    scaffoldBackground: const Color(0xFFF0F4F9),
    subThemesData: const FlexSubThemesData(
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      defaultRadius: 8,
    ),
  ).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A73E8),
      brightness: Brightness.light,
      surface: const Color(0xFFF0F4F9),
      onSurface: const Color(0xFF1F1F1F),
      onSurfaceVariant: const Color(0xFF474747),
      surfaceContainerLow: const Color(0xFFE9EEF6),
      surfaceContainer: const Color(0xFFFFFFFF),
      primary: const Color(0xFF1A73E8),
    ),
    extensions: [
      const AppColors(
        success: Color(0xFF28A745),
        onSuccess: Color(0xFFFFFFFF),
      ),
    ],
    hoverColor: const Color(0xFFE9EEF6),
    highlightColor: const Color(0xFFE9EEF6),
    splashColor: const Color(0xFFE9EEF6),
  );

  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFFC4C7C5),
      primaryContainer: Color(0xFF303132),
      secondary: Color(0xFFC4C7C5),
      secondaryContainer: Color(0xFF303132),
      tertiary: Color(0xFFC4C7C5),
      tertiaryContainer: Color(0xFF303132),
      error: Color(0xFFCF6679),
    ),
    surface: const Color(0xFF000000),
    scaffoldBackground: const Color(0xFF000000),
    subThemesData: const FlexSubThemesData(
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      defaultRadius: 8,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
  ).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFC4C7C5),
      brightness: Brightness.dark,
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFE3E3E3),
      onSurfaceVariant: const Color(0xFFC4C7C5),
      surfaceContainerLow: const Color(0xFF1E1F20),
      surfaceContainer: const Color(0xFF1E1F20),
      surfaceContainerHigh: const Color(0xFF1E1F20),
      primary: const Color(0xFFC4C7C5),
      onPrimary: const Color(0xFF000000),
      outline: const Color(0xFF444746),
      outlineVariant: const Color(0xFF444746),
    ),
    extensions: [
      const AppColors(
        success: Color(0xFF48C76F),
        onSuccess: Color(0xFF000000),
      ),
    ],
  );

  static ThemeData getTheme(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => light,
      ThemeMode.dark => dark,
      ThemeMode.system => light,
    };
  }
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.onSuccess,
  });

  final Color success;
  final Color onSuccess;

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
