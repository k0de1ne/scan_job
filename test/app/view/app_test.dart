import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/app/view/app.dart';
import 'package:scan_job/chat/view/chat_page.dart';
import 'package:scan_job/l10n/l10n.dart';

void main() {
  group('App', () {
    testWidgets('renders ChatPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(ChatPage), findsOneWidget);
    });

    group('Scalable Localization & UI Tests', () {
      // Список страниц для проверки. Сюда добавляйте новые экраны по мере разработки.
      final pagesToTest = <Widget>[
        const ChatPage(),
      ];

      for (final page in pagesToTest) {
        for (final locale in AppLocalizations.supportedLocales) {
          testWidgets(
            'Page ${page.runtimeType} renders correctly in $locale without overflow',
            (tester) async {
              // Устанавливаем узкий размер экрана для поиска переполнений (Overflow)
              tester.view.physicalSize = const Size(320, 480);
              tester.view.devicePixelRatio = 1.0;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);

              await tester.pumpWidget(
                MaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: locale,
                  theme: ThemeData(useMaterial3: true),
                  home: page,
                ),
              );

              await tester.pumpAndSettle();

              // Проверяем, что в рендере нет исключений (включая RenderFlex overflow)
              expect(tester.takeException(), isNull);

              // Сбрасываем размер экрана для других тестов
              await tester.binding.setSurfaceSize(null);
            },
          );
        }
      }
    });
  });
}
