import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan_job/home/view/home_page.dart';
import 'package:scan_job/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // High-quality Material 3 theme using FlexColorScheme
      theme: FlexThemeData.light(
        scheme: FlexScheme.greyLaw,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          // Modern tight rounded corners (8px instead of 28px)
          defaultRadius: 8,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        swapLegacyOnMaterial3: true,
        // Using Inter font for professional look
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.greyLaw,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          defaultRadius: 8,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
