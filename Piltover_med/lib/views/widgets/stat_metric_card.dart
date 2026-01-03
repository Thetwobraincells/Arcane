import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import 'glowing_card.dart';

class StatMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isAlert;

  const StatMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAlert
        ? const Color(AppConstants.hextechGold)
        : const Color(AppConstants.hextechBlue);

    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                if (isAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Color(AppConstants.hextechGold),
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

