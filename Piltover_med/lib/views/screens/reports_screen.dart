import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../widgets/hextech_header.dart';
import '../widgets/test_result_card.dart';
import '../widgets/glowing_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportController>().loadSampleData();
    });
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
              return const Center(
                child: Text(
                  'No reports available',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            // Calculate statistics
            final stats = _calculateStats(reports);

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
                // Test Status Distribution
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildStatusDistribution(stats),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Health Overview
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
                          child: TestResultCard(report: report),
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

  Map<String, dynamic> _calculateStats(reports) {
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
              const Color(0xFF8B5CF6), // Purple
            ),
            const SizedBox(height: 12),
            _buildStatusBar(
              'Critical',
              stats['criticalCount'],
              stats['totalTests'],
              const Color(0xFFEF4444), // Red (soft)
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

