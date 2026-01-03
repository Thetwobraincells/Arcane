import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class HextechHeader extends StatelessWidget {
  const HextechHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(AppConstants.hextechBlue).withOpacity(0.2),
            const Color(AppConstants.arcanePurple).withOpacity(0.2),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.hextechBlue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(AppConstants.hextechBlue),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(AppConstants.hextechBlue),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(AppConstants.hextechBlue),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Hextech-Powered Medical Dashboard',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

