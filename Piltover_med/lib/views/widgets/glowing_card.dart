import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? const Color(AppConstants.hextechBlue);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

