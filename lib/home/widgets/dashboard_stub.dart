import 'package:flutter/material.dart';

class DashboardStub extends StatelessWidget {
  const DashboardStub({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.dashboard_outlined,
          size: 64,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'Dashboard coming soon',
          style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
