import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';
import '../services/gemini_service.dart';
import '../views/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../utils/report_parser.dart';
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

      // 4. ✅ Start AI analysis in background (non-blocking)
      // Use provided fileName or try to extract from input
      final detectedFileName = fileName ?? _getFileName(imageInput);
      _analyzeInBackground(reportId, imageInput, context, fileName: detectedFileName);

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
    BuildContext context, {
    String? fileName,
  }) async {
    try {
      LabReport? aiReport;

      // Check if we are on a mobile platform for On-Device OCR
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
         try {
           print("Starting On-Device OCR...");
           final inputImage = InputImage.fromFile(imageInput as File);
           final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
           final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
           
           print("OCR Text: ${recognizedText.text.substring(0, 50)}..."); // Debug log

           // Parse the text locally
           aiReport = ReportParser.parse(recognizedText.text, reportId);
           
           textRecognizer.close();
         } catch (e) {
           print("On-Device OCR Failed: $e");
           // Fallback to Cloud if local fails? Or just rethrow?
           // For now, let's catch and continue to Cloud if user wants, 
           // but the requirement is "Instead of cloud", so maybe just fail or return empty?
           // Let's try cloud as fallback for now or proceed with what we have.
         }
      }

      // If On-Device produced a valid report with results, use it.
      // Otherwise, or if on unsupported platform, you might want to fall back to Gemini 
      // OR just return the empty/partial report.
      
      // For this task, "Instead of sending the image to the cloud", strictly implies local only.
      // However, if I am on Windows, I cannot do local.
      // I will keep the Gemini call as a fallback for non-mobile for now, 
      // but on mobile it will use the parsed report.
      
      if (aiReport == null || aiReport.testResults.isEmpty) {
         // Fallback or Non-Mobile flow
         // Note: User asked to REPLACE, but on Windows we can't run ML Kit.
         // If we are on Windows, we will use Gemini as a dev fallback, or show error?
         // I'll leave Gemini enabled for non-mobile so I can verify on Windows if needed (though user said on-device).
         // Actually, I'll prefer the OCR result if it exists.
      }
      
      // If we used OCR, aiReport is populated.
      // If we didn't (e.g. Windows), we need to fetch it (or error out if strict).
      
      // ⚠️ CHANGED: User requested NO CLOUD analysis for images.
      // If On-Device OCR failed or is not available (e.g. Windows), we fail.
      if (aiReport == null) {
         // Previously: aiReport = await _aiService.analyzeImage(imageInput, fileName: fileName);
         throw Exception("On-device analysis failed or platform not supported. Cloud analysis is disabled.");
      }

      // ✅ NEW: Validate against Standards (Firebase)
      if (aiReport != null && context.mounted) {
        try {
          final standardsService = context.read<StandardsService>();
          final userService = context.read<UserService>();
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
              );

              // Update the result with new status and range info
              enrichedResults.add(TestResult(
                testName: result.testName,
                value: result.value,
                unit: result.unit,
                status: evaluation.status, // Overwrite status based on standard
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
      print("Analysis Error: $e");
      
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