import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/app/app.dart';
import 'package:scan_job/home/view/home_page.dart';
import 'package:scan_job/l10n/l10n.dart';

void main() {
  group('App', () {
    testWidgets('renders HomePage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(HomePage), findsOneWidget);
    });

    group('Scalable Localization & UI Tests', () {
      // Список страниц для проверки. Сюда добавляйте новые экраны по мере разработки.
      final pagesToTest = <Widget>[
        const HomePage(),
      ];

      for (final page in pagesToTest) {
        for (final locale in AppLocalizations.supportedLocales) {
          testWidgets(
            'Page ${page.runtimeType} renders correctly in $locale without overflow',
            (tester) async {
              // Устанавливаем узкий размер экрана для поиска переполнений (Overflow)
              await tester.binding.setSurfaceSize(const Size(320, 480));

              await tester.pumpWidget(
                MaterialApp(
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: locale,
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
