import 'package:flutter/material.dart';
import 'package:scan_job/home/widgets/dashboard_stub.dart';
import 'package:scan_job/l10n/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: const Center(
        child: DashboardStub(),
      ),
    );
  }
}
