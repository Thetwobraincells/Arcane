import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';
import '../services/gemini_service.dart';

class ReportController extends ChangeNotifier {
  List<LabReport> _reports = [];
  bool _isLoading = false;

  // Initialize our new AI Service
  final GeminiService _aiService = GeminiService();

  List<LabReport> get reports => _reports;
  bool get isLoading => _isLoading;

  /// NEW: Picks an image, sends it to Gemini, and adds the result to the list
  Future<void> uploadAndAnalyzeReport() async {
    try {
      // 1. Open the File Picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      // 2. Check if user actually selected a file
      if (result != null && result.files.single.path != null) {
        
        // Start Loading (shows spinner in UI)
        _isLoading = true;
        notifyListeners();

        File imageFile = File(result.files.single.path!);

        try {
          // 3. Send file to Gemini Service for analysis
          LabReport newReport = await _aiService.analyzeImage(imageFile);

          // 4. Add the new report to the TOP of the list
          _reports.insert(0, newReport);
          
        } catch (e) {
          // Handle AI or Parsing errors
          print("Error during AI Analysis: $e");
          // Optional: You could add an error message variable here to show in the UI
        }

        // Stop Loading
        _isLoading = false;
        notifyListeners();
      } else {
        // User canceled the picker
        print("User canceled file picking");
      }
    } catch (e) {
      print("General Error: $e");
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
