import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../models/lab_report_model.dart';
import '../widgets/hextech_header.dart';
import '../widgets/test_result_card.dart';
import '../widgets/glowing_card.dart';
import '../widgets/upload_modal.dart';
import '../widgets/hover_button.dart';
import '../widgets/bobbing_hextech_core.dart';
import '../../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Sample data loading removed - reports will only show uploaded/analyzed reports
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ReportController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(AppConstants.hextechBlue),
                ),
              );
            }

            final reports = controller.reports;
            
            if (reports.isEmpty) {
              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: HextechHeader(),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: _buildEmptyState(),
                    ),
                  ),
                ],
              );
            }

            // ✅ Only calculate stats from completed reports
            final completedReports = reports.where((r) => r.status == ReportStatus.completed).toList();
            final stats = _calculateStats(completedReports);

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: HextechHeader(),
                ),
                // AI Warning at the top
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildAIWarning(),
                  ),
                ),
                // Test Status Distribution (only if we have completed reports)
                if (completedReports.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: _buildStatusDistribution(stats),
                    ),
                  ),
                if (completedReports.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Health Overview (only if we have completed reports)
                if (completedReports.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: _buildTrendSection(stats),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Reports List
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = reports[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildReportCard(report), // ✅ New method handles all states
                        );
                      },
                      childCount: reports.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ NEW: Smart card builder based on report status
  Widget _buildReportCard(LabReport report) {
    switch (report.status) {
      case ReportStatus.processing:
        return _buildProcessingCard(report);
      case ReportStatus.failed:
        return _buildFailedCard(report);
      case ReportStatus.completed:
        return TestResultCard(report: report);
    }
  }

  // ✅ NEW: Processing state card
  Widget _buildProcessingCard(LabReport report) {
    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: BobbingHextechCore(
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analyzing Report...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(AppConstants.hextechBlue),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI is processing your medical report',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppConstants.hextechBlue).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This usually takes 5-10 seconds. Results will appear here automatically.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Failed state card
  Widget _buildFailedCard(LabReport report) {
    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis Failed',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.errorMessage ?? 'Unknown error occurred',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Possible reasons:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Image quality is too low\n'
                    '• Text is not clearly visible\n'
                    '• File format is not supported\n'
                    '• Network connection issue',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<ReportController>().removeReport(report.id);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Remove Report',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<LabReport> reports) {
    int totalTests = 0;
    int normalCount = 0;
    int highCount = 0;
    int lowCount = 0;
    int criticalCount = 0;

    for (var report in reports) {
      totalTests = totalTests + (report.testResults.length as int);
      for (var test in report.testResults) {
        switch (test.status.toLowerCase()) {
          case 'normal':
            normalCount++;
            break;
          case 'high':
            highCount++;
            break;
          case 'low':
            lowCount++;
            break;
          case 'critical':
            criticalCount++;
            break;
        }
      }
    }

    final abnormalCount = highCount + lowCount + criticalCount;
    final normalPercentage = totalTests > 0 ? (normalCount / totalTests * 100) : 0;
    final abnormalPercentage = totalTests > 0 ? (abnormalCount / totalTests * 100) : 0;

    return {
      'totalReports': reports.length,
      'totalTests': totalTests,
      'normalCount': normalCount,
      'highCount': highCount,
      'lowCount': lowCount,
      'criticalCount': criticalCount,
      'abnormalCount': abnormalCount,
      'normalPercentage': normalPercentage,
      'abnormalPercentage': abnormalPercentage,
    };
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GlowingCard(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: Color(AppConstants.hextechBlue),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'No Reports Yet',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                'Upload a medical report to generate insights and track your health data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Upload Button with hover effect
              HoverButton(
                onPressed: () {
                  showUploadModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.hextechBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Report',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.hextechGold).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(AppConstants.hextechGold).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: Color(AppConstants.hextechGold),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Generated Insights',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.hextechGold),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These statistics are AI-generated insights based on your uploaded reports. '
                  'They are not medical advice. Always consult with qualified healthcare providers '
                  'for medical decisions and treatment.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(Map<String, dynamic> stats) {
    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: Color(AppConstants.hextechBlue),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Test Status Distribution',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.hextechBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusBar(
              'Normal',
              stats['normalCount'],
              stats['totalTests'],
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildStatusBar(
              'High',
              stats['highCount'],
              stats['totalTests'],
              const Color(AppConstants.hextechGold),
            ),
            const SizedBox(height: 12),
            _buildStatusBar(
              'Low',
              stats['lowCount'],
              stats['totalTests'],
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 12),
            _buildStatusBar(
              'Critical',
              stats['criticalCount'],
              stats['totalTests'],
              const Color(0xFFEF4444),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection(Map<String, dynamic> stats) {
    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(AppConstants.hextechBlue),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Health Overview',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.hextechBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTrendIndicator(
              'Overall Health Score',
              stats['normalPercentage'],
              stats['normalPercentage'] >= 80 ? 'Excellent' : stats['normalPercentage'] >= 60 ? 'Good' : 'Needs Attention',
              stats['normalPercentage'] >= 80 ? const Color(0xFF10B981) : stats['normalPercentage'] >= 60 ? const Color(AppConstants.hextechBlue) : const Color(AppConstants.hextechGold),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              icon: Icons.lightbulb_outline,
              title: 'AI Insight',
              message: stats['abnormalCount'] == 0
                  ? 'All test results are within normal ranges. Keep up the good health practices!'
                  : stats['criticalCount'] > 0
                      ? 'Some critical values detected. Please consult your healthcare provider immediately.'
                      : 'Some values are outside normal range. Monitor these closely and discuss with your doctor.',
              color: stats['criticalCount'] > 0
                  ? const Color(0xFFEF4444)
                  : stats['abnormalCount'] > 0
                      ? const Color(AppConstants.hextechGold)
                      : const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(String label, double percentage, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            percentage >= 80 ? Icons.check_circle : Icons.info_outline,
            color: color,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
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
    );
  }
}