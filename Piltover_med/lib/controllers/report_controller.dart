import 'package:flutter/foundation.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';

class ReportController extends ChangeNotifier {
  List<LabReport> _reports = [];
  bool _isLoading = false;

  List<LabReport> get reports => _reports;
  bool get isLoading => _isLoading;

  // Enhanced sample data for demonstration with trends
  void loadSampleData() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _reports = [
        // Report 1 - 14 days ago
        LabReport(
          id: '1',
          patientName: 'John Doe',
          patientId: 'P001',
          reportDate: DateTime.now().subtract(const Duration(days: 14)),
          testResults: [
            TestResult(
              testName: 'Hemoglobin',
              value: '13.8',
              unit: 'g/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 14)),
            ),
            TestResult(
              testName: 'Glucose (Fasting)',
              value: '92',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 14)),
            ),
            TestResult(
              testName: 'Total Cholesterol',
              value: '185',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 14)),
            ),
          ],
          notes: 'Routine checkup',
        ),

        // Report 2 - 10 days ago
        LabReport(
          id: '2',
          patientName: 'John Doe',
          patientId: 'P001',
          reportDate: DateTime.now().subtract(const Duration(days: 10)),
          testResults: [
            TestResult(
              testName: 'Blood Pressure (Systolic)',
              value: '128',
              unit: 'mmHg',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 10)),
            ),
            TestResult(
              testName: 'Blood Pressure (Diastolic)',
              value: '82',
              unit: 'mmHg',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 10)),
            ),
            TestResult(
              testName: 'Heart Rate',
              value: '72',
              unit: 'bpm',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 10)),
            ),
          ],
          notes: 'Follow-up vitals check',
        ),

        // Report 3 - 7 days ago
        LabReport(
          id: '3',
          patientName: 'Jane Smith',
          patientId: 'P002',
          reportDate: DateTime.now().subtract(const Duration(days: 7)),
          testResults: [
            TestResult(
              testName: 'Total Cholesterol',
              value: '225',
              unit: 'mg/dL',
              status: 'high',
              date: DateTime.now().subtract(const Duration(days: 7)),
            ),
            TestResult(
              testName: 'LDL Cholesterol',
              value: '145',
              unit: 'mg/dL',
              status: 'high',
              date: DateTime.now().subtract(const Duration(days: 7)),
            ),
            TestResult(
              testName: 'HDL Cholesterol',
              value: '48',
              unit: 'mg/dL',
              status: 'low',
              date: DateTime.now().subtract(const Duration(days: 7)),
            ),
            TestResult(
              testName: 'Triglycerides',
              value: '165',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 7)),
            ),
          ],
          notes: 'Lipid panel - needs lifestyle modification',
        ),

        // Report 4 - 5 days ago
        LabReport(
          id: '4',
          patientName: 'John Doe',
          patientId: 'P001',
          reportDate: DateTime.now().subtract(const Duration(days: 5)),
          testResults: [
            TestResult(
              testName: 'Hemoglobin',
              value: '14.2',
              unit: 'g/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 5)),
            ),
            TestResult(
              testName: 'White Blood Cells',
              value: '7.2',
              unit: '10³/µL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 5)),
            ),
            TestResult(
              testName: 'Platelets',
              value: '245',
              unit: '10³/µL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 5)),
            ),
          ],
          notes: 'Complete blood count',
        ),

        // Report 5 - 3 days ago
        LabReport(
          id: '5',
          patientName: 'Michael Johnson',
          patientId: 'P003',
          reportDate: DateTime.now().subtract(const Duration(days: 3)),
          testResults: [
            TestResult(
              testName: 'Glucose (Fasting)',
              value: '118',
              unit: 'mg/dL',
              status: 'high',
              date: DateTime.now().subtract(const Duration(days: 3)),
            ),
            TestResult(
              testName: 'HbA1c',
              value: '6.2',
              unit: '%',
              status: 'high',
              date: DateTime.now().subtract(const Duration(days: 3)),
            ),
            TestResult(
              testName: 'Creatinine',
              value: '1.1',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 3)),
            ),
          ],
          notes: 'Pre-diabetes screening',
        ),

        // Report 6 - 2 days ago
        LabReport(
          id: '6',
          patientName: 'Emily Davis',
          patientId: 'P004',
          reportDate: DateTime.now().subtract(const Duration(days: 2)),
          testResults: [
            TestResult(
              testName: 'TSH',
              value: '2.8',
              unit: 'mIU/L',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
            TestResult(
              testName: 'Free T4',
              value: '1.2',
              unit: 'ng/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
            TestResult(
              testName: 'Vitamin D',
              value: '18',
              unit: 'ng/mL',
              status: 'low',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
          notes: 'Thyroid function test',
        ),

        // Report 7 - 1 day ago (Yesterday)
        LabReport(
          id: '7',
          patientName: 'John Doe',
          patientId: 'P001',
          reportDate: DateTime.now().subtract(const Duration(days: 1)),
          testResults: [
            TestResult(
              testName: 'Glucose (Fasting)',
              value: '95',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 1)),
            ),
            TestResult(
              testName: 'Total Cholesterol',
              value: '178',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          notes: 'Follow-up after lifestyle changes',
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  void addReport(LabReport report) {
    _reports.add(report);
    notifyListeners();
  }

  void removeReport(String id) {
    _reports.removeWhere((report) => report.id == id);
    notifyListeners();
  }

  // Helper method to get statistics
  Map<String, dynamic> getStatistics() {
    int totalTests = 0;
    int normalCount = 0;
    int highCount = 0;
    int lowCount = 0;
    int criticalCount = 0;

    for (var report in _reports) {
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
      'totalReports': _reports.length,
      'totalTests': totalTests,
      'normalCount': normalCount,
      'highCount': highCount,
      'lowCount': lowCount,
      'criticalCount': criticalCount,
    };
  }
}