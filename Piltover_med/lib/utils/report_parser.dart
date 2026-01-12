
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';

class ReportParser {
  /// Parses raw text into a LabReport object
  static LabReport parse(String text, String reportId) {
    String patientName = _extractPatientName(text) ?? 'Unknown Patient';
    String patientId = _extractPatientId(text) ?? 'Unknown ID';
    DateTime reportDate = _extractDate(text) ?? DateTime.now();
    List<TestResult> testResults = _extractTestResults(text, reportDate);

    return LabReport(
      id: reportId,
      patientName: patientName,
      patientId: patientId,
      reportDate: reportDate,
      testResults: testResults,
      notes: 'Generated via On-Device OCR',
      status: ReportStatus.completed,
    );
  }

  static String? _extractPatientName(String text) {
    // Look for common patterns for patient name
    final nameRegex = RegExp(
      r'(?:Patient Name|Name|Pt Name)\s*[:\-\.]?\s*([A-Za-z\s\.]+)',
      caseSensitive: false,
    );
    final match = nameRegex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  static String? _extractPatientId(String text) {
    // Look for ID patterns
    final idRegex = RegExp(
      r'(?:Patient ID|ID|MRN|Ref No)\s*[:\-\.]?\s*([A-Za-z0-9\-\.]+)',
      caseSensitive: false,
    );
    final match = idRegex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  static DateTime? _extractDate(String text) {
    // Look for date patterns (DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD)
    final dateRegex = RegExp(
      r'(?:Date|Report Date|Collected)\s*[:\-\.]?\s*(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})',
      caseSensitive: false,
    );
    final match = dateRegex.firstMatch(text);
    if (match != null) {
      final dateStr = match.group(1);
      // Basic parsing - assuming standard formats. 
      // In a real app, use a robust date parser.
      // For now, return existing if parse fails, or TryParse.
      // This is a placeholder for actual date parsing logic.
      try {
        // Very basic attempt: just return now if parsing is complex without intl
        // In production, use DateFormat from intl package
        return DateTime.now(); 
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<TestResult> _extractTestResults(String text, DateTime date) {
    List<TestResult> results = [];
    final lines = text.split('\n');

    // Common units to identify test result lines
    final units = ['mg/dL', 'g/dL', '%', 'mmol/L', 'µg/dL', 'U/L', 'mcg/dL', '/mm3', '10^3/uL', '10^6/uL'];

    for (var line in lines) {
      // Logic: If line contains a number and a known unit, it's likely a result
      bool hasUnit = units.any((u) => line.contains(u));
      
      // Look for a number
      final numberRegex = RegExp(r'(\d+(?:\.\d+)?)');
      final numberMatch = numberRegex.firstMatch(line);

      if (hasUnit && numberMatch != null) {
        // Heuristic extraction
        // Assume format: [Test Name] [Value] [Unit] [Range/Flag]
        
        // Value is the first number found
        String val = numberMatch.group(1)!;
        
        // Unit is the one found
        String unit = units.firstWhere((u) => line.contains(u));
        
        // Test Name is likely everything before the value or the first part of the line
        // This is very rough and would need significant refinement for real reports
        int valIndex = line.indexOf(val);
        String testName = line.substring(0, valIndex).trim();
        if (testName.endsWith(':') || testName.endsWith('-')) {
             testName = testName.substring(0, testName.length - 1).trim();
        }
        
        if (testName.isEmpty) continue; // Skip invalid lines

        // Determine status (mock logic for now since range parsing is hard)
        String status = 'Normal';
        if (line.toLowerCase().contains('high') || line.contains('H ')) status = 'High';
        if (line.toLowerCase().contains('low') || line.contains('L ')) status = 'Low';
        if (line.toLowerCase().contains('critical')) status = 'Critical';

        results.add(TestResult(
          testName: testName,
          value: val,
          unit: unit,
          status: status,
          date: date,
          simpleExplanation: 'Extracted from image',
        ));
      }
    }
    
    return results;
  }
}
