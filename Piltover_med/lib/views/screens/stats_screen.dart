import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../utils/constants.dart';
import '../widgets/glowing_card.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
              return _buildEmptyState();
            }

            // Calculate statistics
            final stats = _calculateStats(reports);

            return CustomScrollView(
              slivers: [
                // Header Section
                SliverToBoxAdapter(
                  child: _buildHeader(stats),
                ),

                // Overview Cards
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildOverviewCards(stats),
                  ),
                ),

                // Status Distribution
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildStatusDistribution(stats),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Trend Indicators
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildTrendSection(stats),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Recent Activity Timeline
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildRecentActivity(reports),
                  ),
                ),

                // Disclaimer
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildDisclaimer(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

  Widget _buildHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(AppConstants.hextechBlue).withOpacity(0.1),
            const Color(AppConstants.arcanePurple).withOpacity(0.05),
          ],
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
                  color: const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppConstants.hextechBlue).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(AppConstants.hextechBlue),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Analytics',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(AppConstants.hextechBlue).withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Insights from ${stats['totalReports']} uploaded reports',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
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

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Tests',
            value: stats['totalTests'].toString(),
            icon: Icons.science_outlined,
            color: const Color(AppConstants.hextechBlue),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Normal',
            value: stats['normalCount'].toString(),
            icon: Icons.check_circle_outline,
            color: const Color(0xFF10B981), // Green
            subtitle: '${stats['normalPercentage'].toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Alerts',
            value: stats['abnormalCount'].toString(),
            icon: Icons.warning_amber_outlined,
            color: const Color(AppConstants.hextechGold),
            subtitle: '${stats['abnormalPercentage'].toStringAsFixed(0)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return GlowingCard(
      glowColor: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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

  Widget _buildRecentActivity(reports) {
    final recentReports = reports.take(3).toList();
    
    return GlowingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Color(AppConstants.hextechBlue),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Activity',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.hextechBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentReports.map((report) => _buildActivityItem(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(report) {
    final daysAgo = DateTime.now().difference(report.reportDate).inDays;
    final timeText = daysAgo == 0 ? 'Today' : daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Color(AppConstants.hextechBlue),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lab Report - ${report.patientName}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${report.testResults.length} tests • $timeText',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
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
            Icons.info_outline,
            color: Color(AppConstants.hextechGold),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These statistics are AI-generated insights based on your uploaded reports. '
              'They are not medical advice. Always consult with qualified healthcare providers '
              'for medical decisions and treatment.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Data Available',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(AppConstants.hextechBlue),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload medical reports to view health analytics and insights',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}