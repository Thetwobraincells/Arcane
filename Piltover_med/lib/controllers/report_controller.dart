import 'package:flutter/foundation.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';

class ReportController extends ChangeNotifier {
  List<LabReport> _reports = [];
  bool _isLoading = false;

  List<LabReport> get reports => _reports;
  bool get isLoading => _isLoading;

  // Sample data for demonstration
  void loadSampleData() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _reports = [
        LabReport(
          id: '1',
          patientName: 'John Doe',
          patientId: 'P001',
          reportDate: DateTime.now().subtract(const Duration(days: 2)),
          testResults: [
            TestResult(
              testName: 'Hemoglobin',
              value: '14.5',
              unit: 'g/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
            TestResult(
              testName: 'Glucose',
              value: '95',
              unit: 'mg/dL',
              status: 'normal',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        ),
        LabReport(
          id: '2',
          patientName: 'Jane Smith',
          patientId: 'P002',
          reportDate: DateTime.now().subtract(const Duration(days: 1)),
          testResults: [
            TestResult(
              testName: 'Cholesterol',
              value: '220',
              unit: 'mg/dL',
              status: 'high',
              date: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
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
}

