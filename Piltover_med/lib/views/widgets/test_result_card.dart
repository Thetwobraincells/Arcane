import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/lab_report_model.dart';

class TestResultCard extends StatelessWidget {
  final LabReport report;

  const TestResultCard({
    super.key,
    required this.report,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF8B5CF6);
      case 'normal':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF0EA5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${report.patientId}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDate(report.reportDate),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0EA5E9),
                    ),
                  ),
                ),
              ],
            ),

            // Summary if available
            if (report.notes != null && report.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF0EA5E9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.notes!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 16),

            // Test Results
            ...report.testResults.map((test) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.testName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${test.value} ${test.unit}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            if (test.simpleExplanation != null && test.simpleExplanation!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                test.simpleExplanation!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(test.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getStatusColor(test.status).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          test.status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(test.status),
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}