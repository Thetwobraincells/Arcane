import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';
import '../services/gemini_service.dart';
import '../views/screens/main_scaffold.dart';
import 'package:flutter/material.dart';

class ReportController extends ChangeNotifier {
  List<LabReport> _reports = [];
  bool _isLoading = false;

  // Initialize our new AI Service
  final GeminiService _aiService = GeminiService();

  List<LabReport> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> analyzeFile(File imageFile, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

  try {
      // 1. Call AI Service
      LabReport newReport = await _aiService.analyzeImage(imageFile);

      // 2. Add to List
      _reports.insert(0, newReport);

      // 3. Success Feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Analysis Complete!"),
            backgroundColor: Color(0xFF00D4FF), // Hextech Blue
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 4. Navigation Magic (Switch to Reports Tab)
      mainScaffoldKey.currentState?.goToTab(1);

    } catch (e) {
      print("AI Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Analysis Failed: ${e.toString().split(':').last.trim()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Existing Sample Data Logic (Kept for the demo) ---
  void loadSampleData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _reports = [
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
        // ... You can keep the rest of your sample data here if you want ...
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
