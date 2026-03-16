// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Gemini';

  @override
  String get homePageMessage => 'Приложение Scan Job запущено!';

  @override
  String get chatTitle => 'Gemini';

  @override
  String get chatGreeting => 'Gemini, ваш персональный ИИ-помощник';

  @override
  String get chatWelcomeMessage => 'Привет! Чем я могу помочь вам сегодня?';

  @override
  String get chatInputPlaceholder => 'Спросите Gemini';

  @override
  String get chatSendButtonTooltip => 'Отправить';

  @override
  String get chatActionWrite => 'Напиши текст';

  @override
  String get chatActionPlan => 'Планируйте';

  @override
  String get chatActionExplore => 'Исследуйте';

  @override
  String get chatActionLearn => 'Учитесь';

  @override
  String get chatTools => 'Инструменты';

  @override
  String get chatModelFast => 'Быстрая';

  @override
  String get chatSignIn => 'Войти';

  @override
  String get chatNavAbout => 'О Gemini';

  @override
  String get chatNavApp => 'Приложение Gemini';

  @override
  String get chatNavSubs => 'Подписки';

  @override
  String get chatNavBusiness => 'Для бизнеса';

  @override
  String get chatFooterTerms =>
      'Действуют Условия использования Google и Политика конфиденциальности Google. Gemini – это ИИ. Он может ошибаться.';
}
