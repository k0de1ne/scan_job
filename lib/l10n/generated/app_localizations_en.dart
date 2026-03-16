// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Scan Job';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get chatTitle => 'Scan Job';

  @override
  String get chatGreeting => 'Scan Job, your professional career assistant';

  @override
  String get chatInputPlaceholder => 'How can I help you today?';

  @override
  String get chatNavHistory => 'History';

  @override
  String get chatNavHelp => 'Help';

  @override
  String get chatNavSettings => 'Settings';

  @override
  String get chatNavAbout => 'About Scan Job';

  @override
  String get chatNavApp => 'Scan Job App';

  @override
  String get chatFooterTerms =>
      'Scan Job is an AI-powered professional tool. Please verify critical information.';
}
