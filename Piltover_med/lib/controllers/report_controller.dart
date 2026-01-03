import 'dart:io';
import 'dart:typed_data';
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

  // ✅ REFACTORED: Non-blocking async flow
  Future<void> analyzeFile(dynamic imageInput, BuildContext context) async {
    try {
      // 1. ✅ Create placeholder report IMMEDIATELY
      final reportId = DateTime.now().millisecondsSinceEpoch.toString();
      final placeholderReport = LabReport.processing(
        id: reportId,
        filePath: _getFilePathForDisplay(imageInput),
      );

      // 2. ✅ Add to list and notify (UI updates instantly)
      _reports.insert(0, placeholderReport);
      notifyListeners();

      // 3. ✅ Navigate to Reports screen NOW (don't wait for AI)
      mainScaffoldKey.currentState?.goToTab(1);

      // 4. ✅ Start AI analysis in background (non-blocking)
      _analyzeInBackground(reportId, imageInput, context);

    } catch (e) {
      print("Error starting analysis: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start analysis: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ NEW: Background processing method
  Future<void> _analyzeInBackground(
    String reportId,
    dynamic imageInput,
    BuildContext context,
  ) async {
    try {
      // Call AI Service (this takes 5-10 seconds)
      final aiReport = await _aiService.analyzeImage(imageInput);

      // Find the placeholder report and update it
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWithCompleted(
          patientName: aiReport.patientName,
          patientId: aiReport.patientId,
          testResults: aiReport.testResults,
          notes: aiReport.notes,
        );
        notifyListeners(); // ✅ UI updates with real data

        // Success feedback (non-intrusive)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Analysis Complete!"),
              backgroundColor: Color(0xFF10B981), // Green
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print("AI Error: $e");
      
      // Mark report as failed
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWithFailed(
          e.toString().split(':').last.trim(),
        );
        notifyListeners(); // ✅ UI shows error state

        // Error feedback
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Analysis Failed: ${e.toString().split(':').last.trim()}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  // ✅ NEW: Helper to get file path for display
  String? _getFilePathForDisplay(dynamic input) {
    if (input is File) {
      return input.path;
    } else if (input is Uint8List) {
      return 'uploaded_file.${input.length > 0 ? "bin" : "unknown"}';
    }
    return null;
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
          status: ReportStatus.completed, // ✅ Mark sample data as completed
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

  Map<String, dynamic> getStatistics() {
    int totalTests = 0;
    int normalCount = 0;
    int highCount = 0;
    int lowCount = 0;
    int criticalCount = 0;

    // ✅ Only count completed reports for statistics
    final completedReports = _reports.where((r) => r.status == ReportStatus.completed);

    for (var report in completedReports) {
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
      'totalReports': completedReports.length,
      'totalTests': totalTests,
      'normalCount': normalCount,
      'highCount': highCount,
      'lowCount': lowCount,
      'criticalCount': criticalCount,
    };
  }
}