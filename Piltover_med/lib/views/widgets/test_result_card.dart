import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/lab_report_model.dart';
import '../../utils/constants.dart';
import 'glowing_card.dart';

class TestResultCard extends StatelessWidget {
  final LabReport report;

  const TestResultCard({
    super.key,
    required this.report,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'critical':
        return Colors.red;
      case 'high':
        return const Color(AppConstants.hextechGold);
      case 'low':
        return Colors.orange;
      default:
        return const Color(AppConstants.hextechBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.patientName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${report.patientId}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.hextechBlue)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(AppConstants.hextechBlue),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    report.reportDate.toString().split(' ')[0],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(AppConstants.hextechBlue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display simplified report summary if available
            if (report.notes != null && report.notes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: const Color(AppConstants.hextechBlue),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What This Means:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(AppConstants.hextechBlue),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.notes!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Divider(color: Color(0xFF2A2F4A)),
            const SizedBox(height: 16),
            ...report.testResults.map((test) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.testName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${test.value} ${test.unit}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            // Display simple explanation if available
                            if (test.simpleExplanation != null && test.simpleExplanation!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                test.simpleExplanation!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white60,
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(test.status)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(test.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          test.status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(test.status),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

