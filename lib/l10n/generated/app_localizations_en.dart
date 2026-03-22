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
  String get chatSidebarNewChat => 'New Chat';

  @override
  String get chatSidebarSearchPlaceholder => 'Search chats...';

  @override
  String get chatSidebarChatListTitle => 'Your chats';

  @override
  String get chatSidebarEmptySearch => 'No chats found';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeTitle => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsLlmTitle => 'LLM Configuration';

  @override
  String get settingsLlmBaseUrl => 'Base URL';

  @override
  String get settingsLlmApiKey => 'API Key';

  @override
  String get settingsLlmModelName => 'Model Name';

  @override
  String get settingsLlmPriceInput => 'Price per 1M Input Tokens (\$)';

  @override
  String get settingsLlmPriceOutput => 'Price per 1M Output Tokens (\$)';

  @override
  String get settingsLlmHelp =>
      'Configure your local (LM Studio) or remote OpenAI-compatible API.';

  @override
  String get chatNavAbout => 'About Scan Job';

  @override
  String get chatNavApp => 'Scan Job App';

  @override
  String get chatThinkingProcess => 'Thinking';

  @override
  String get chatPlan => 'Action Plan';

  @override
  String get chatToolCall => 'Tool Call';

  @override
  String get chatToolResult => 'Result';

  @override
  String get chatInputHero => 'Your personal AI career assistant';

  @override
  String get chatInputFooter => 'Scan Job is an AI. It can make mistakes.';

  @override
  String get chatStepCompleted => 'Completed';

  @override
  String get chatStepActive => 'Active';

  @override
  String get chatModelQuick => 'Quick';

  @override
  String get chatFooterTerms =>
      'Scan Job is a professional AI tool. Please verify important information.';

  @override
  String get thoughtStepThinkingTitle => 'Thinking';

  @override
  String get thoughtStepThinkingSubTitle => 'Analysis';

  @override
  String thoughtStepToolTitle(int index) {
    return 'Tool $index';
  }

  @override
  String get thoughtStepToolStarting => 'Starting...';

  @override
  String thoughtStepToolCompletedTitle(int index) {
    return 'Tool $index completed';
  }

  @override
  String get thoughtStepToolDone => 'Done.';

  @override
  String get thoughtStepToolRunning => 'Running...';

  @override
  String get dashboardComingSoon => 'Dashboard coming soon';

  @override
  String get codeTitle => 'Code';

  @override
  String get codeCopy => 'Copy';

  @override
  String get codeCopied => 'Copied';

  @override
  String get chatErrorTitle => 'Error';

  @override
  String get chatErrorServerBusy =>
      'Server is busy or unreachable. Please check your connection or LLM settings.';

  @override
  String get chatErrorNoApiKey => 'API Key is missing. Please check settings.';

  @override
  String get chatErrorGeneric => 'Something went wrong. Please try again.';
}
