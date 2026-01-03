import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/upload_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors from your palette
    final Color neonCyan = const Color(0xFF00F0FF);
    final Color textGray = const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by MainScaffold
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. The Glowing Orb Container
              Container(
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A1E3A),
                  boxShadow: [
                    BoxShadow(
                      color: neonCyan.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // --- CHANGED: Using your Asset Image here ---
                    ClipOval(
                      child: Image.asset(
                        "assets/images/hexcore.png", // <--- YOUR FILE
                        height: 260, // Slightly smaller than container to fit inside
                        width: 260,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to Icon if image fails to load
                          return Icon(
                            Icons.medical_services,
                            size: 100,
                            color: neonCyan.withOpacity(0.5),
                          );
                        },
                      ),
                    ),
                    
                    // The "Verified" Badge (stays on top)
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          border: Border.all(color: neonCyan.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: neonCyan, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Verified",
                              style: TextStyle(color: neonCyan, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // 2. Headlines
              Text(
                "Decode Your",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Medical Reports",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: neonCyan,
                  shadows: [
                    Shadow(
                      color: neonCyan.withOpacity(0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "AI-powered explanations. Clear insights.\nNo medical jargon.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: textGray,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // 3. Upload Button - NOW TRIGGERS UNIFIED UPLOAD MODAL
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: neonCyan.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    showUploadModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    side: BorderSide(color: neonCyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, color: neonCyan),
                      const SizedBox(width: 12),
                      Text(
                        "UPLOAD REPORT",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 4. Security Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: textGray),
                  const SizedBox(width: 8),
                  Text(
                    "Encrypted & Secure HIPAA Compliant",
                    style: TextStyle(color: textGray, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
