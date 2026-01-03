import 'test_result_model.dart';

class LabReport {
  final String id;
  final String patientName;
  final String patientId;
  final DateTime reportDate;
  final List<TestResult> testResults;
  final String? notes;

  LabReport({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.reportDate,
    required this.testResults,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'patientId': patientId,
        'reportDate': reportDate.toIso8601String(),
        'testResults': testResults.map((tr) => tr.toJson()).toList(),
        'notes': notes,
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
      );
}

