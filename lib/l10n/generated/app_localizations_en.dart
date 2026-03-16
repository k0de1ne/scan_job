// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gemini';

  @override
  String get homePageMessage => 'Scan Job Application Started!';

  @override
  String get chatTitle => 'Gemini';

  @override
  String get chatGreeting => 'Gemini, your personal AI assistant';

  @override
  String get chatWelcomeMessage => 'Hello! How can I help you today?';

  @override
  String get chatInputPlaceholder => 'Ask Gemini';

  @override
  String get chatSendButtonTooltip => 'Send';

  @override
  String get chatActionWrite => 'Write text';

  @override
  String get chatActionPlan => 'Plan';

  @override
  String get chatActionExplore => 'Explore';

  @override
  String get chatActionLearn => 'Learn';

  @override
  String get chatTools => 'Tools';

  @override
  String get chatModelFast => 'Fast';

  @override
  String get chatSignIn => 'Sign in';

  @override
  String get chatNavAbout => 'About Gemini';

  @override
  String get chatNavApp => 'Gemini App';

  @override
  String get chatNavSubs => 'Subscriptions';

  @override
  String get chatNavBusiness => 'For Business';

  @override
  String get chatFooterTerms =>
      'Google Terms of Service and Privacy Policy apply. Gemini is an AI and may be inaccurate.';
}
