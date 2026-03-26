import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Scan Job'**
  String get appTitle;

  /// The title for the dashboard page
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// The title for the chat page
  ///
  /// In en, this message translates to:
  /// **'Scan Job'**
  String get chatTitle;

  /// Greeting message in chat
  ///
  /// In en, this message translates to:
  /// **'Scan Job, your professional career assistant'**
  String get chatGreeting;

  /// Placeholder for the chat input field
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get chatInputPlaceholder;

  /// Navigation history label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get chatNavHistory;

  /// Navigation help label
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get chatNavHelp;

  /// Navigation settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get chatNavSettings;

  /// No description provided for @chatSidebarNewChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get chatSidebarNewChat;

  /// No description provided for @chatSidebarSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search chats...'**
  String get chatSidebarSearchPlaceholder;

  /// No description provided for @chatSidebarChatListTitle.
  ///
  /// In en, this message translates to:
  /// **'Your chats'**
  String get chatSidebarChatListTitle;

  /// No description provided for @chatSidebarEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get chatSidebarEmptySearch;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLlmTitle.
  ///
  /// In en, this message translates to:
  /// **'LLM Configuration'**
  String get settingsLlmTitle;

  /// No description provided for @settingsLlmBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get settingsLlmBaseUrl;

  /// No description provided for @settingsLlmApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settingsLlmApiKey;

  /// No description provided for @settingsLlmModelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get settingsLlmModelName;

  /// No description provided for @settingsLlmPriceInput.
  ///
  /// In en, this message translates to:
  /// **'Price per 1M Input Tokens (\$)'**
  String get settingsLlmPriceInput;

  /// No description provided for @settingsLlmPriceOutput.
  ///
  /// In en, this message translates to:
  /// **'Price per 1M Output Tokens (\$)'**
  String get settingsLlmPriceOutput;

  /// No description provided for @settingsLlmHelp.
  ///
  /// In en, this message translates to:
  /// **'Configure your local (LM Studio) or remote OpenAI-compatible API.'**
  String get settingsLlmHelp;

  /// Navigation about label
  ///
  /// In en, this message translates to:
  /// **'About Scan Job'**
  String get chatNavAbout;

  /// Navigation app label
  ///
  /// In en, this message translates to:
  /// **'Scan Job App'**
  String get chatNavApp;

  /// No description provided for @chatThinkingProcess.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get chatThinkingProcess;

  /// No description provided for @chatPlan.
  ///
  /// In en, this message translates to:
  /// **'Action Plan'**
  String get chatPlan;

  /// No description provided for @chatToolCall.
  ///
  /// In en, this message translates to:
  /// **'Tool Call'**
  String get chatToolCall;

  /// No description provided for @chatToolResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get chatToolResult;

  /// No description provided for @chatInputHero.
  ///
  /// In en, this message translates to:
  /// **'Your personal AI career assistant'**
  String get chatInputHero;

  /// No description provided for @chatInputFooter.
  ///
  /// In en, this message translates to:
  /// **'Scan Job is an AI. It can make mistakes.'**
  String get chatInputFooter;

  /// No description provided for @chatStepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get chatStepCompleted;

  /// No description provided for @chatStepActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get chatStepActive;

  /// No description provided for @chatModelQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get chatModelQuick;

  /// No description provided for @chatFooterTerms.
  ///
  /// In en, this message translates to:
  /// **'Scan Job is a professional AI tool. Please verify important information.'**
  String get chatFooterTerms;

  /// No description provided for @thoughtStepThinkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thoughtStepThinkingTitle;

  /// No description provided for @thoughtStepThinkingSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get thoughtStepThinkingSubTitle;

  /// Title for a tool call step
  ///
  /// In en, this message translates to:
  /// **'Tool {index}'**
  String thoughtStepToolTitle(int index);

  /// No description provided for @thoughtStepToolStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get thoughtStepToolStarting;

  /// Title for a completed tool call step
  ///
  /// In en, this message translates to:
  /// **'Tool {index} completed'**
  String thoughtStepToolCompletedTitle(int index);

  /// No description provided for @thoughtStepToolDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get thoughtStepToolDone;

  /// No description provided for @thoughtStepToolRunning.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get thoughtStepToolRunning;

  /// No description provided for @dashboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Dashboard coming soon'**
  String get dashboardComingSoon;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeTitle;

  /// No description provided for @codeCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get codeCopy;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get codeCopied;

  /// No description provided for @chatErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get chatErrorTitle;

  /// No description provided for @chatErrorServerBusy.
  ///
  /// In en, this message translates to:
  /// **'Server is busy or unreachable. Please check your connection or LLM settings.'**
  String get chatErrorServerBusy;

  /// No description provided for @chatErrorNoApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key is missing. Please check settings.'**
  String get chatErrorNoApiKey;

  /// No description provided for @chatErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get chatErrorGeneric;

  /// No description provided for @chatErrorLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Trial period ended'**
  String get chatErrorLimitReached;

  /// No description provided for @chatErrorLimitReachedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have used up your free limit. A subscription option for unlimited access will be available soon! In the meantime, you can add your own API key in settings.'**
  String get chatErrorLimitReachedSubtitle;

  /// No description provided for @sidebarAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get sidebarAccountsTitle;

  /// No description provided for @sidebarAccountsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No accounts connected'**
  String get sidebarAccountsEmpty;

  /// No description provided for @sidebarAccountsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get sidebarAccountsAdd;

  /// No description provided for @sidebarAccountId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String sidebarAccountId(Object id);

  /// No description provided for @chatNavSync.
  ///
  /// In en, this message translates to:
  /// **'Sync Devices'**
  String get chatNavSync;

  /// No description provided for @syncDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Your Chats'**
  String get syncDialogTitle;

  /// No description provided for @syncDialogGenerate.
  ///
  /// In en, this message translates to:
  /// **'Show QR to Sync'**
  String get syncDialogGenerate;

  /// No description provided for @syncDialogScan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR to Sync'**
  String get syncDialogScan;

  /// No description provided for @syncDialogStatusInitial.
  ///
  /// In en, this message translates to:
  /// **'Sync your chat history between devices.'**
  String get syncDialogStatusInitial;

  /// No description provided for @syncDialogStatusGenerating.
  ///
  /// In en, this message translates to:
  /// **'Room ID: {id}\nScan this with another device to start syncing.'**
  String syncDialogStatusGenerating(String id);

  /// No description provided for @syncDialogStatusScanning.
  ///
  /// In en, this message translates to:
  /// **'Looking for device...'**
  String get syncDialogStatusScanning;

  /// No description provided for @syncDialogStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get syncDialogStatusConnecting;

  /// No description provided for @syncDialogStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Direct P2P connection established!'**
  String get syncDialogStatusConnected;

  /// No description provided for @syncDialogStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully!'**
  String get syncDialogStatusSuccess;

  /// No description provided for @syncDialogStatusFailure.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncDialogStatusFailure(String error);

  /// No description provided for @syncDialogSend.
  ///
  /// In en, this message translates to:
  /// **'Send My Chats'**
  String get syncDialogSend;

  /// No description provided for @syncDialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get syncDialogClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
