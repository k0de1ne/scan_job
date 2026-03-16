import 'package:flutter/material.dart';

class GeminiSparkleIcon extends StatelessWidget {
  const GeminiSparkleIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFF9B72CB),
            Color(0xFFD96570),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Icon(
        Icons.auto_awesome,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
