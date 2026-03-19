import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/home/widgets/dashboard_stub.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('DashboardStub', () {
    testWidgets('renders DashboardStub with icon and text', (tester) async {
      await tester.pumpApp(const DashboardStub());
      expect(find.byType(DashboardStub), findsOneWidget);
      expect(find.text('Dashboard coming soon'), findsOneWidget);
    });
  });
}
