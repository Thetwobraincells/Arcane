
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReportParser {
  /// Parses raw text into a LabReport object.
  /// Modified to accept [RecognizedText] for better layout analysis.
  static LabReport parse(dynamic textInput, String reportId) {
    String text;
    
    // If we have the full OCR object, we can reconstruct the lines better
    if (textInput is RecognizedText) {
      text = _reconstructText(textInput);
    } else {
      text = textInput.toString();
    }

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

  /// Reconstructs text attempts to align lines physically (Row-based)
  /// instead of Block-based (Column-based)
  static String _reconstructText(RecognizedText recognizedText) {
    List<TextLine> allLines = [];
    for (var block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    // Sort heavily by Top (Y), then by Left (X)
    // We group lines that are roughly on the same Y-axis
    allLines.sort((a, b) {
      // 10px threshold for being on the same line
      if ((a.boundingBox.top - b.boundingBox.top).abs() < 15) {
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      }
      return a.boundingBox.top.compareTo(b.boundingBox.top);
    });

    StringBuffer sb = StringBuffer();
    double lastTop = -100;
    
    for (var line in allLines) {
      // If we jumped down significantly, new line
      if ((line.boundingBox.top - lastTop).abs() > 15) {
        if (sb.isNotEmpty) sb.writeln();
        lastTop = line.boundingBox.top;
      } else {
        // Same line, add space
        sb.write(" "); 
      }
      sb.write(line.text);
    }
    
    return sb.toString();
  }

  static String? _extractPatientName(String text) {
    // 1. Look for explicit "Name: Value" pattern (Strongest signal)
    final explicitRegex = RegExp(
      r'(?:Patient Name|Name|Pt Name)\s*[:\-\.]?\s*([A-Za-z\.\,\s]+?)(?=\s*(?:Age|Sex|ID|Date|Ref|Dr|\n|$))',
      caseSensitive: false,
    );
    final explicitMatch = explicitRegex.firstMatch(text);
    if (explicitMatch != null) {
      String name = explicitMatch.group(1)?.trim() ?? "";
      if (name.isNotEmpty && name.length > 3) return name;
    }

    // 2. Fallback: Look for "Lastname, Firstname" format (Common in med reports)
    // Matches: ALL CAPS text with a comma, e.g., "MANALO, JUSTINE NICOLE"
    final looseNameRegex = RegExp(
      r'(?<=^|\n)\s*([A-Z][A-Z\s]+,\s*[A-Z][A-Z\s]+)(?=\s*(?:Age|Sex|ID|\n|$))',
    );
    final looseMatch = looseNameRegex.firstMatch(text);
    if (looseMatch != null) {
       return looseMatch.group(1)?.trim();
    }

    return null;
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

  static final Map<String, String> _testDescriptions = {
    'hemoglobin': 'Oxygen-carrying protein in red blood cells.',
    'hematocrit': 'Percentage of blood volume occupied by red blood cells.',
    'rbc': 'Number of red blood cells (erythrocytes).',
    'wbc': 'Number of white blood cells (leukocytes), fights infection.',
    'platelet': 'Cells that help blood clot.',
    'mcv': 'Average size of your red blood cells.',
    'mch': 'Average amount of hemoglobin in each red blood cell.',
    'mchc': 'Concentration of hemoglobin in a given volume of red blood cells.',
    'neutrophil': 'Type of WBC that eats bacteria and fights infection.',
    'lymphocyte': 'Type of WBC that produces antibodies and fights viruses.',
    'monocyte': 'Type of WBC that cleans up dead cells.',
    'eosinophil': 'Type of WBC involved in allergic reactions and parasites.',
    'basophil': 'Type of WBC involved in allergic reactions.',
    'glucose': 'Sugar level in your blood.',
    'protein': 'Amount of protein in urine (Proteinuria).',
    'ph': 'Acidity or alkalinity level.',
    'specific gravity': 'Concentration of the urine.',
    'color': 'Visual appearance of the sample.',
    'transparency': 'Clarity of the sample.',
    'pus cells': 'Sign of infection (pyuria).',
    'epithelial': 'Cells lining the urinary tract.',
    'bacteria': 'Presence of bacteria suggesting infection.',
    'mucus': 'Mucus threads in the sample.',
    'bilirubin': 'Breakdown product of blood, checks liver function.',
    'ketone': 'Byproduct of fat breakdown.',
  };

  static List<TestResult> _extractTestResults(String text, DateTime date) {
    List<TestResult> results = [];
    final lines = text.split('\n');

    // 1. KNOWN TESTS
    final knownTests = [
      'hemoglobin', 'hematocrit', 'rbc', 'wbc', 'mcv', 'mch', 'mchc', 'platelet',
      'neutrophil', 'lymphocyte', 'monocyte', 'eosinophil', 'basophil',
      'epithelial', 'mucus', 'bacteria', 'pus cells', 'color', 'transparency', // UA
      'glucose', 'protein', 'ph', 'specific gravity', 'bilirubin', 'ketone', 'urobilinogen', // Chem
      'consistency' // Fecalysis
    ];

    // 2. KNOWN UNITS
    final units = [
      'mg/dl', 'g/dl', '%', 'mmol/l', 'µg/dl', 'ug/dl', 'u/l', 'mcg/dl', 
      '/mm3', '10^3/ul', '10^6/ul', 'fl', 'pg', 'g/l', 'iu/l', '/hpf', '/lpf'
    ];
    
    // TRACK SECTIONS
    String currentSection = ""; // "CBC", "UA", "FA", "SEROLOGY"

    for (var line in lines) {
      final lowerLine = line.toLowerCase();
      
      // Detect Section Headers
      if (lowerLine.contains('complete blood count') || lowerLine.contains('cbc')) {
        currentSection = "CBC";
        continue;
      } else if (lowerLine.contains('urinalysis') || lowerLine.contains('(ua)')) {
        currentSection = "UA";
        continue;
      } else if (lowerLine.contains('fecalysis') || lowerLine.contains('(fa)')) {
        currentSection = "FA";
        continue;
      } else if (lowerLine.contains('serology')) {
        currentSection = "SEROLOGY";
        continue;
      }

      // -- STRATEGY 1: Check for Known Test Name --
      String? matchedTest;
        // "Smart" Matching Strategy
        // Short words (pH, RBC) or common words (Color) need strict boundaries to avoid false positives (e.g. "ph" in "Lymphocyte")
        // Long words (Hemoglobin, Neutrophil) are safe to loose match
        
      for (final test in knownTests) {
        bool isAmbiguous = test.length <= 4 || ['color', 'consistency', 'bacteria', 'mucus', 'pus cells', 'epithelial cells'].contains(test);
        
        if (isAmbiguous) {
           // Strict Word Boundary for ambiguous terms
           final regex = RegExp(r'\b' + RegExp.escape(test) + r'\b', caseSensitive: false);
           if (regex.hasMatch(line)) {
             matchedTest = test;
             // Don't break yet, check section validity
           }
        } else {
           // Loose match for distinct terms
           if (lowerLine.contains(test)) {
             matchedTest = test;
             // Don't break yet
           }
        }

        if (matchedTest != null) {
           // SECTION FILTER: Prevent ghosts
           // If we are strictly in CBC section, ignore UA/FA specific tests
           bool isUAorFATest = ['color', 'transparency', 'pus cells', 'epithelial cells', 'bacteria', 'mucus', 'consistency', 'glucose', 'protein', 'bilirubin', 'ketone'].contains(matchedTest);
           
           if (currentSection == "CBC" && isUAorFATest) {
              matchedTest = null; // Ignore ghost
              continue; 
           }
           
           break; // Valid match found
        }
      }

      // -- STRATEGY 2: Check for Unit --
      bool hasUnit = units.any((u) => lowerLine.contains(u));
      
      final numberRegex = RegExp(r'(\d+(?:\.\d+)?)');
      final numberMatch = numberRegex.firstMatch(line);

      // Special handling for nominal values
      bool isNominal = false;
      String val = "";
      
      if (matchedTest != null && numberMatch == null) {
         final nominalRegex = RegExp(r'(Negative|Positive|Clear|Yellow|Light Yellow|Light Brown|Brown|Semi Formed|Soft|Watery|Amorphous|Rare|Few|Moderate|Many|Nonreactive|Reactive)', caseSensitive: false);
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
           if (unitIndex != -1) {
             unit = line.substring(unitIndex, unitIndex + matchedUnit.length);
           }
        }

        // Determine Test Name properly
        String testName = "";
        if (matchedTest != null) {
           // Capitalize
           testName = matchedTest[0].toUpperCase() + matchedTest.substring(1);
           if (['rbc', 'wbc', 'mcv', 'mch', 'mchc', 'ph'].contains(matchedTest)) {
             testName = matchedTest.toUpperCase();
           }
        } else {
           int valIndex = line.indexOf(val);
           if (valIndex > 0) {
              testName = line.substring(0, valIndex).trim();
           }
        }
        
        testName = testName.replaceAll(RegExp(r'[:\-\.]+$'), '').trim();
        
        // SCOPE TEST NAME BASED ON SECTION
        // Handle RBC collisions
        if (testName == "RBC") {
          if (currentSection == "UA") testName = "RBC (Urine)";
          else if (currentSection == "FA") testName = "RBC (Stool)";
        }
        if (testName == "Bacteria" || testName == "Mucus" || testName == "Epithelial Cells" || testName == "Pus Cells") {
           if (currentSection == "UA") testName = "$testName (Urine)";
           else if (currentSection == "FA") testName = "$testName (Stool)";
        }
        if ((testName == "Color" || testName == "Consistency")) {
           if (currentSection == "FA") testName = "$testName (Stool)";
           else if (currentSection == "UA") testName = "$testName (Urine)";
        }
        
        // Blocklist
        final blocklist = ['male', 'female', 'age', 'sex', 'years', 'months', 'adult', 'child', 'reference', 'range', 'units', 'result', 'flag', 'physical', 'microscopic', 'chemical'];
        if (matchedTest == null && blocklist.contains(testName.toLowerCase())) continue;

        if (testName.isEmpty || testName.length < 2) continue;
        
        // INFER UNITS (Fine-tuning)
        if (testName == "Hematocrit" && unit.isEmpty && val.contains('.')) {
          double? v = double.tryParse(val);
          if (v != null && v < 1.0) unit = "ratio";
        }
        if (testName == "Neutrophil" && unit.isEmpty && val.contains('.')) {
          double? v = double.tryParse(val);
          if (v != null && v < 1.0) unit = "fraction"; // or ratio
        }
        if (testName == "Lymphocyte" && unit.isEmpty && val.contains('.')) {
           double? v = double.tryParse(val);
           if (v != null && v < 1.0) unit = "fraction";
        }

        // Determine Status
        String status = 'Normal';
        if (line.contains('High') || line.contains(' H ')) status = 'High';
        if (line.contains('Low') || line.contains(' L ')) status = 'Low';
        if (lowerLine.contains('critical')) status = 'Critical';
        
        if (val.toLowerCase() == 'positive' || val.toLowerCase() == 'reactive') status = 'High';

        // GET DESCRIPTION
        String description = 'Extracted from image';
        if (matchedTest != null) {
           description = _testDescriptions[matchedTest] ?? description;
        }

        results.add(TestResult(
          testName: testName,
          value: val,
          unit: unit,
          status: status,
          date: date,
          simpleExplanation: description,
        ));
      }
    }
    
    return results;
  }
}
