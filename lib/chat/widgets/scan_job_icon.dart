import 'package:flutter/material.dart';

class ScanJobIcon extends StatelessWidget {
  const ScanJobIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
      Icons.center_focus_weak_rounded,
      size: size,
      color: colorScheme.primary,
    );
  }
}
