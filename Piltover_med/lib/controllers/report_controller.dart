import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';
import '../services/gemini_service.dart';
import '../views/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/standards_service.dart';
import '../services/user_service.dart';

class ReportController extends ChangeNotifier {
  List<LabReport> _reports = [];
  bool _isLoading = false;

  // Initialize our new AI Service
  final GeminiService _aiService = GeminiService();

  List<LabReport> get reports => _reports;
  bool get isLoading => _isLoading;

  // ✅ REFACTORED: Non-blocking async flow
  Future<void> analyzeFile(dynamic imageInput, BuildContext context, {String? fileName}) async {
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
      
      // Capture Services before async/context loss
      final standardsService = context.read<StandardsService>();
      final userService = context.read<UserService>();

      // 4. ✅ Start AI analysis in background (non-blocking)
      // Use provided fileName or try to extract from input
      final detectedFileName = fileName ?? _getFileName(imageInput);
      _analyzeInBackground(reportId, imageInput, standardsService, userService, fileName: detectedFileName);

    } catch (e) {
      print("Error starting analysis: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar( // Context safe here? Maybe.
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
    StandardsService standardsService,
    UserService userService, {
    String? fileName,
  }) async {
    try {
      LabReport? aiReport;

      // Direct AI-based analysis (Gemini only)
      try {
        print("☁️ Running Gemini analysis (no on-device OCR)...");
        aiReport = await _aiService.analyzeImage(imageInput, fileName: fileName);
      } catch (e) {
        print("Gemini Analysis Failed: $e");
      }

      if (aiReport == null) {
         throw Exception("AI analysis failed. Gemini did not return results.");
      }

      // ✅ NEW: Validate against Standards (Firebase)
      // No context.mounted check needed for services since we passed them in
      if (aiReport != null) {
        try {
          final user = userService.currentUser;

          List<TestResult> enrichedResults = [];

          for (var result in aiReport.testResults) {
            // Parse value to double for comparison
            // Remove any non-numeric chars except dot
            String cleanVal = result.value.replaceAll(RegExp(r'[^\d.]'), '');
            double? val = double.tryParse(cleanVal);
            
            if (val != null) {
              final evaluation = await standardsService.evaluateResult(
                testName: result.testName,
                value: val,
                sex: user.sex,
                age: user.age,
                currentUnit: result.unit,
              );

              // Preserve original status if we couldn't validate against standards
              String finalStatus = evaluation.status == 'Unknown' 
                  ? result.status  // Keep original parsed status
                  : evaluation.status;  // Use validated status

              // Update the result with new status and range info
              enrichedResults.add(TestResult(
                testName: result.testName,
                value: result.value,
                unit: result.unit,
                status: finalStatus,
                date: result.date,
                simpleExplanation: '${result.simpleExplanation ?? ""} (Standard range: ${evaluation.rangeString})',
              ));
            } else {
              enrichedResults.add(result);
            }
          }
          
          // Replace results with enriched ones
          aiReport = aiReport!.copyWithCompleted(
            patientName: aiReport.patientName,
            patientId: aiReport.patientId,
            testResults: enrichedResults,
            notes: aiReport.notes,
          );
          
          // ✅ Generate AI Summary (Gemini)
          try {
             print("🧠 Generating AI Summary...");
             final summary = await _aiService.summarizeResults({
               'patientName': aiReport!.patientName,
               'reportDate': aiReport!.reportDate.toIso8601String(),
               'testResults': enrichedResults.map((t) => {
                 'testName': t.testName,
                 'value': t.value,
                 'unit': t.unit,
                 'status': t.status, // Pass the CORRECTED status
               }).toList(),
             });
             
             aiReport = aiReport!.copyWithCompleted(
               patientName: aiReport.patientName,
               patientId: aiReport.patientId,
               testResults: enrichedResults,
               notes: summary,
             );
          } catch (e) {
             print("Summary Generation Failed: $e");
          }
          
        } catch (e) {
          print("Standards Check Failed: $e");
          // Continue with original report if standards fail
        }
      }

      // Find the placeholder report and update it
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWithCompleted(
          patientName: aiReport!.patientName,
          patientId: aiReport!.patientId,
          testResults: aiReport!.testResults,
          notes: aiReport!.notes,
        );
        notifyListeners(); // ✅ UI updates with real data
      }
    } catch (e) {
      print("Analysis Error: $e");
      
      // Mark report as failed
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWithFailed(
          e.toString().split(':').last.trim(),
        );
        notifyListeners(); // ✅ UI shows error state
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
  
  // ✅ NEW: Helper to get file name for mime type detection
  String? _getFileName(dynamic input) {
    if (input is File) {
      return input.path.split('/').last;
    }
    // For Uint8List, we'll need to get the name from upload controller
    // This will be handled in the upload modal
    return null;
  }

  // Sample data method removed - reports will only show uploaded/analyzed reports

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