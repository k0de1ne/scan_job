// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Scan Job';

  @override
  String get dashboardTitle => 'Панель управления';

  @override
  String get chatTitle => 'Scan Job';

  @override
  String get chatGreeting =>
      'Scan Job, ваш профессиональный помощник в карьере';

  @override
  String get chatInputPlaceholder => 'Чем я могу помочь?';

  @override
  String get chatNavHistory => 'История';

  @override
  String get chatNavHelp => 'Помощь';

  @override
  String get chatNavSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsThemeTitle => 'Внешний вид';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Темная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsLlmTitle => 'Конфигурация LLM';

  @override
  String get settingsLlmBaseUrl => 'Base URL';

  @override
  String get settingsLlmApiKey => 'API Key';

  @override
  String get settingsLlmModelName => 'Model Name';

  @override
  String get settingsLlmHelp =>
      'Настройте ваш локальный (LM Studio) или удаленный OpenAI-совместимый API.';

  @override
  String get chatNavAbout => 'О Scan Job';

  @override
  String get chatNavApp => 'Приложение Scan Job';

  @override
  String get chatNewChat => 'Новый чат';

  @override
  String get chatThinkingProcess => 'Размышление';

  @override
  String get chatPlan => 'План действий';

  @override
  String get chatToolCall => 'Вызов инструмента';

  @override
  String get chatToolResult => 'Результат';

  @override
  String get chatInputHero => 'Ваш личный карьерный ИИ-ассистент';

  @override
  String get chatInputFooter => 'Scan Job – это ИИ. Он может ошибаться.';

  @override
  String get chatStepCompleted => 'Выполнено';

  @override
  String get chatStepActive => 'В процессе';

  @override
  String get chatModelQuick => 'Быстрая';

  @override
  String get chatFooterTerms =>
      'Scan Job — это профессиональный инструмент на базе ИИ. Пожалуйста, проверяйте важную информацию.';

  @override
  String get thoughtStepAnalysisTitle => 'Анализ запроса';

  @override
  String get thoughtStepAnalysisContent => 'Инициализация...';

  @override
  String get thoughtStepThinkingTitle => 'Размышление';

  @override
  String get thoughtStepThinkingSubTitle => 'Анализ';

  @override
  String thoughtStepToolTitle(int index) {
    return 'Инструмент $index';
  }

  @override
  String get thoughtStepToolStarting => 'Запуск...';

  @override
  String thoughtStepToolCompletedTitle(int index) {
    return 'Инструмент $index выполнен';
  }

  @override
  String get thoughtStepToolDone => 'Готово.';

  @override
  String get thoughtStepToolRunning => 'В процессе...';

  @override
  String get dashboardComingSoon => 'Панель управления скоро появится';

  @override
  String get codeTitle => 'Код';

  @override
  String get codeCopy => 'Копировать';

  @override
  String get codeCopied => 'Скопировано';

  @override
  String get chatErrorTitle => 'Ошибка';

  @override
  String get chatErrorServerBusy =>
      'Сервер занят или недоступен. Проверьте соединение или настройки LLM.';

  @override
  String get chatErrorNoApiKey => 'API-ключ отсутствует. Проверьте настройки.';

  @override
  String get chatErrorGeneric =>
      'Что-то пошло не так. Пожалуйста, попробуйте еще раз.';
}
