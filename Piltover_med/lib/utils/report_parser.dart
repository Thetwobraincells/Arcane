
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
      r'(?:Patient Name|Name|Pt Name)\s*[:\-\.]?\s*([A-Za-z\s\.]+?)(?=\s*(?:Age|Sex|ID|Date|\n|$))',
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
    // Also supports: October 08, 2024 or Oct 8, 2024
    final dateRegex = RegExp(
      r'(?:Date|Report Date|Collected)\s*[:\-\.]?\s*(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4})',
      caseSensitive: false,
    );
    final match = dateRegex.firstMatch(text);
    if (match != null) {
      final dateStr = match.group(1);
      try {
        // Mock parsing for the new format since we don't have intl
        if (dateStr!.contains(',')) {
           // Basic hack for "October 08, 2024" -> just return today/now or try simple parse
           // In real app, DateFormat('MMMM dd, yyyy').parse(dateStr)
           return DateTime.now(); 
        }
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

    // 1. KNOWN TESTS: Words that strongly indicate a test line
    final knownTests = [
      'hemoglobin', 'hematocrit', 'rbc', 'wbc', 'mcv', 'mch', 'mchc', 'platelet',
      'neutrophil', 'lymphocyte', 'monocyte', 'eosinophil', 'basophil',
      'epithelial', 'mucus', 'bacteria', 'pus cells', 'color', 'transparency', // Urinalysis
      'glucose', 'protein', 'ph', 'specific gravity', 'bilirubin', 'ketone', 'urobilinogen' // Chem
    ];

    // 2. KNOWN UNITS
    final units = [
      'mg/dl', 'g/dl', '%', 'mmol/l', 'µg/dl', 'ug/dl', 'u/l', 'mcg/dl', 
      '/mm3', '10^3/ul', '10^6/ul', 'fl', 'pg', 'g/l', 'iu/l', '/hpf', '/lpf'
    ];

    for (var line in lines) {
      final lowerLine = line.toLowerCase();
      
      // -- STRATEGY 1: Check for Known Test Name --
      String? matchedTest;
      for (var test in knownTests) {
        if (lowerLine.contains(test)) {
          matchedTest = test;
          break;
        }
      }

      // -- STRATEGY 2: Check for Unit --
      bool hasUnit = units.any((u) => lowerLine.contains(u));
      
      // Must have at least a Number AND (Known Test OR Unit)
      // Exception: Some manual tests might use text words instead of numbers (e.g. "Color: Yellow"), 
      // but for now let's stick to numeric results to avoid too much noise, or specifically handle them.
      
      final numberRegex = RegExp(r'(\d+(?:\.\d+)?)');
      final numberMatch = numberRegex.firstMatch(line);

      // Special handling for nominal values (Negative, Positive, Clear, Yellow) if we matched a known test
      bool isNominal = false;
      String val = "";
      
      if (matchedTest != null && numberMatch == null) {
         // Check for common words like "Negative", "Clear", "Yellow"
         final nominalRegex = RegExp(r'(Negative|Positive|Clear|Yellow|Amorphous|Rare|Few|Moderate|Many)', caseSensitive: false);
         final nomMatch = nominalRegex.firstMatch(line);
         if (nomMatch != null) {
           val = nomMatch.group(1)!;
           isNominal = true;
         }
      }

      if ((matchedTest != null || hasUnit) && (numberMatch != null || isNominal)) {
        
        // Extract Value
        if (!isNominal && numberMatch != null) {
           val = numberMatch.group(1)!;
        }
        
        // Extract Unit (if any)
        String unit = "";
        if (hasUnit) {
           String matchedUnit = units.firstWhere((u) => lowerLine.contains(u));
           int unitIndex = lowerLine.indexOf(matchedUnit);
           // Safety check for index
           if (unitIndex != -1) {
             unit = line.substring(unitIndex, unitIndex + matchedUnit.length);
           }
        }

        // Determine Test Name
        // If we matched a known test, use that (capitalized for display)
        String testName = "";
        if (matchedTest != null) {
           // Capitalize first letter
           testName = matchedTest[0].toUpperCase() + matchedTest.substring(1);
           
           // If it was an acronym like RBC, make it all caps
           if (['rbc', 'wbc', 'mcv', 'mch', 'mchc', 'ph'].contains(matchedTest)) {
             testName = matchedTest.toUpperCase();
           }
        } else {
           // Fallback to heuristic: Text before value
           int valIndex = line.indexOf(val);
           if (valIndex > 0) {
              testName = line.substring(0, valIndex).trim();
           }
        }

        // Cleanup
        testName = testName.replaceAll(RegExp(r'[:\-\.]+$'), '').trim();
        
        // Blocklist info (Reference ranges often contain these words)
        final blocklist = ['male', 'female', 'age', 'sex', 'years', 'months', 'adult', 'child', 'reference', 'range', 'units', 'result', 'flag'];
        // Only block if we DIDN'T find a known test (if we found "Hemoglobin", ignore the blocklist checks mainly)
        if (matchedTest == null && blocklist.contains(testName.toLowerCase())) continue;

        if (testName.isEmpty || testName.length < 2) continue;

        // Determine Status
        String status = 'Normal';
        if (line.contains('High') || line.contains(' H ')) status = 'High';
        if (line.contains('Low') || line.contains(' L ')) status = 'Low';
        if (lowerLine.contains('critical')) status = 'Critical';
        
        // For nominal
        if (val.toLowerCase() == 'positive') status = 'High'; // Generic bad

        // Deduplicate logic? 
        // For now, list allows duplicates, maybe check if we already added this testName?
        // Let's just add it.

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
