import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/upload_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo / Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Color(0xFF0EA5E9),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Piltover Medical',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Main Illustration Area
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/hexcore.png",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.analytics,
                            size: 120,
                            color: const Color(0xFF0EA5E9).withOpacity(0.3),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Headline
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Understand Your',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Medical Reports',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0EA5E9),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI-powered insights in plain language.\nNo medical jargon, just clarity.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      showUploadModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: const Color(0xFF0EA5E9).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Upload Report',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Security Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: const Color(0xFF64748B).withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Secure & Private • HIPAA Compliant',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B).withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}