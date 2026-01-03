import 'test_result_model.dart';

// ✅ NEW: Report status enum
enum ReportStatus { processing, completed, failed }

class LabReport {
  final String id;
  final String patientName;
  final String patientId;
  final DateTime reportDate;
  final List<TestResult> testResults;
  final String? notes;
  
  // ✅ NEW: Status tracking for async AI processing
  final ReportStatus status;
  final String? filePath; // For reference (optional)
  final String? errorMessage; // For failed state

  LabReport({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.reportDate,
    required this.testResults,
    this.notes,
    this.status = ReportStatus.completed, // Default for existing reports
    this.filePath,
    this.errorMessage,
  });

  // ✅ NEW: Helper to create processing placeholder
  factory LabReport.processing({
    required String id,
    String? filePath,
  }) {
    return LabReport(
      id: id,
      patientName: 'Analyzing...',
      patientId: 'PROCESSING',
      reportDate: DateTime.now(),
      testResults: [],
      notes: 'AI analysis in progress...',
      status: ReportStatus.processing,
      filePath: filePath,
    );
  }

  // ✅ NEW: Helper to mark as failed
  LabReport copyWithFailed(String error) {
    return LabReport(
      id: id,
      patientName: 'Analysis Failed',
      patientId: patientId,
      reportDate: reportDate,
      testResults: testResults,
      notes: notes,
      status: ReportStatus.failed,
      filePath: filePath,
      errorMessage: error,
    );
  }

  // ✅ NEW: Helper to update with completed data
  LabReport copyWithCompleted({
    required String patientName,
    required String patientId,
    required List<TestResult> testResults,
    String? notes,
  }) {
    return LabReport(
      id: id,
      patientName: patientName,
      patientId: patientId,
      reportDate: reportDate,
      testResults: testResults,
      notes: notes,
      status: ReportStatus.completed,
      filePath: filePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'patientId': patientId,
        'reportDate': reportDate.toIso8601String(),
        'testResults': testResults.map((tr) => tr.toJson()).toList(),
        'notes': notes,
        'status': status.name,
        'filePath': filePath,
        'errorMessage': errorMessage,
      };

  factory LabReport.fromJson(Map<String, dynamic> json) => LabReport(
        id: json['id'] as String,
        patientName: json['patientName'] as String,
        patientId: json['patientId'] as String,
        reportDate: DateTime.parse(json['reportDate'] as String),
        testResults: (json['testResults'] as List)
            .map((tr) => TestResult.fromJson(tr as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
        status: json['status'] != null 
            ? ReportStatus.values.firstWhere(
                (e) => e.name == json['status'],
                orElse: () => ReportStatus.completed,
              )
            : ReportStatus.completed,
        filePath: json['filePath'] as String?,
        errorMessage: json['errorMessage'] as String?,
      );
}