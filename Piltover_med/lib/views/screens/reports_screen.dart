import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../widgets/hextech_header.dart';
import '../widgets/stat_metric_card.dart';
import '../widgets/test_result_card.dart';
import '../../utils/constants.dart';

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
            final totalTests = reports.fold<int>(
              0,
              (sum, report) => sum + report.testResults.length,
            );
            final criticalResults = reports
                .expand((r) => r.testResults)
                .where((t) => t.status == 'critical' || t.status == 'high')
                .length;

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: HextechHeader(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            title: 'Total Reports',
                            value: reports.length.toString(),
                            icon: Icons.description,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatMetricCard(
                            title: 'Total Tests',
                            value: totalTests.toString(),
                            icon: Icons.science,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatMetricCard(
                            title: 'Alerts',
                            value: criticalResults.toString(),
                            icon: Icons.warning,
                            isAlert: criticalResults > 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
}

