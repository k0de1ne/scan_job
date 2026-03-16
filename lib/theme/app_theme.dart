import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light =
      FlexThemeData.light(
        scheme: FlexScheme.blackWhite,
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
        hoverColor: const Color(0xFF2C2D2D),
        highlightColor: const Color(0xFF2C2D2D),
        splashColor: const Color(0xFF2C2D2D),
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
  );

  static ThemeData getTheme(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => light,
      ThemeMode.dark => dark,
      ThemeMode.system => light,
    };
  }
}
