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
        transparent: Colors.transparent,
      ),
      AppSpacing.defaultSpacing,
      AppRadius.defaultRadius,
      AppShadows(
        small: [
          BoxShadow(
            color: const Color(0xFF1F1F1F).withValues(alpha: 0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        medium: [
          BoxShadow(
            color: const Color(0xFF1F1F1F).withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
        transparent: Colors.transparent,
      ),
      AppSpacing.defaultSpacing,
      AppRadius.defaultRadius,
      AppShadows(
        small: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        medium: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
    required this.transparent,
  });

  final Color success;
  final Color onSuccess;
  final Color transparent;

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? transparent,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      transparent: transparent ?? this.transparent,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
    );
  }
}

class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.mdLarge,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double mdLarge;
  final double lg;
  final double xl;
  final double xxl;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? mdLarge,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      mdLarge: mdLarge ?? this.mdLarge,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: xs + (other.xs - xs) * t,
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      mdLarge: mdLarge + (other.mdLarge - mdLarge) * t,
      lg: lg + (other.lg - lg) * t,
      xl: xl + (other.xl - xl) * t,
      xxl: xxl + (other.xxl - xxl) * t,
    );
  }

  static const defaultSpacing = AppSpacing(
    xs: 4,
    sm: 8,
    md: 12,
    mdLarge: 20,
    lg: 16,
    xl: 24,
    xxl: 32,
  );
}

class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.circle,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double circle;

  @override
  AppRadius copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? circle,
  }) {
    return AppRadius(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      circle: circle ?? this.circle,
    );
  }

  @override
  AppRadius lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;
    return AppRadius(
      xs: xs + (other.xs - xs) * t,
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      lg: lg + (other.lg - lg) * t,
      xl: xl + (other.xl - xl) * t,
      xxl: xxl + (other.xxl - xxl) * t,
      circle: circle + (other.circle - circle) * t,
    );
  }

  static const defaultRadius = AppRadius(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 28,
    circle: 999,
  );
}

class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({
    required this.small,
    required this.medium,
  });

  final List<BoxShadow> small;
  final List<BoxShadow> medium;

  @override
  AppShadows copyWith({
    List<BoxShadow>? small,
    List<BoxShadow>? medium,
  }) {
    return AppShadows(
      small: small ?? this.small,
      medium: medium ?? this.medium,
    );
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      small: BoxShadow.lerpList(small, other.small, t)!,
      medium: BoxShadow.lerpList(medium, other.medium, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  AppRadius get radius => Theme.of(this).extension<AppRadius>()!;
  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;
}
