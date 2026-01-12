import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/report_controller.dart';
import '../../models/lab_report_model.dart';
import '../widgets/test_result_card.dart';
import '../widgets/upload_modal.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<ReportController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0EA5E9),
                ),
              );
            }

            final reports = controller.reports;
            
            if (reports.isEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar()),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: _buildEmptyState()),
                  ),
                ],
              );
            }

            final completedReports = reports.where((r) => r.status == ReportStatus.completed).toList();
            final stats = _calculateStats(completedReports);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar()),
                
                // Medical Disclaimer
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(child: _buildDisclaimer()),
                ),

                // Stats Overview (only if completed reports exist)
                if (completedReports.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverToBoxAdapter(child: _buildStatsOverview(stats)),
                  ),

                // Reports List
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = reports[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildReportCard(report),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment,
              color: Color(0xFF0EA5E9),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Lab Reports',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
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
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Disclaimer',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-generated insights for informational purposes only. Always consult healthcare professionals for medical decisions.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF78350F),
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

  Widget _buildStatsOverview(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Normal',
                  stats['normalCount'].toString(),
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'High',
                  stats['highCount'].toString(),
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Low',
                  stats['lowCount'].toString(),
                  const Color(0xFF8B5CF6),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Critical',
                  stats['criticalCount'].toString(),
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

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

  Widget _buildProcessingCard(LabReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF0EA5E9),
                    strokeWidth: 3,
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
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI is processing your medical report',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
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
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: Color(0xFF64748B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This usually takes 5-10 seconds. Results will appear automatically.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedCard(LabReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
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
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.errorMessage ?? 'Unable to process report',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file,
              color: Color(0xFF0EA5E9),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reports Yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a medical report to get\nAI-powered insights and analysis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              showUploadModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                  ),
                ),
              ],
            ),
          ),
        ],
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
      totalTests += report.testResults.length;
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

    return {
      'totalTests': totalTests,
      'normalCount': normalCount,
      'highCount': highCount,
      'lowCount': lowCount,
      'criticalCount': criticalCount,
    };
  }
}