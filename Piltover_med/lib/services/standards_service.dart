import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_standard_model.dart';

class StandardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // A small memory bank (cache) so we don't ask Firebase for the same thing twice
  final Map<String, MedicalStandard> _cache = {};

  /// Fetches the standard for a specific test (e.g., "Hemoglobin")
  Future<MedicalStandard?> getStandard(String testName) async {
    // 1. Clean up the name: "Hemoglobin" -> "hemoglobin" (must match Document ID)
    final String key = testName.trim().toLowerCase();

    // 2. Check if we already have it in memory
    if (_cache.containsKey(key)) {
      print("⚡ Found $key in local cache!");
      return _cache[key];
    }

    try {
      print("🌐 Fetching $key from Firebase...");
      
      // 3. Go to the 'medical_standards' collection and find the document 'key'
      final docRef = _firestore.collection('medical_standards').doc(key);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        // 4. Convert the data to our Dart Model
        final standard = MedicalStandard.fromSnapshot(key, docSnapshot.data()!);
        
        // 5. Save it to cache for next time
        _cache[key] = standard;
        print("✅ Successfully loaded standard for $key");
        return standard;
      } else {
        print("⚠️ Document for $key does not exist in Database.");
      }
    } catch (e) {
      print("❌ Error fetching standard for $key: $e");
    }
    
    return null; // Return nothing if we failed
  }

  /// Evaluates a test result against the standard for a specific user profile
  Future<EvaluationResult> evaluateResult({
    required String testName,
    required double value,
    required String sex,
    required int age,
    String? currentUnit,
  }) async {
    MedicalStandard? standard = await getStandard(testName);
    
    // Fallback to built-in standards if Firebase doesn't have this test
    if (standard == null) {
      standard = _getBuiltInStandard(testName.toLowerCase());
    }
    
    if (standard == null) {
      return EvaluationResult(
        status: 'Unknown',
        rangeString: 'Include reference range',
        isNormal: true, // Default to true if unknown to avoid alarm
      );
    }
    
    
    // Auto-Convert Units (Fraction vs Percent, g/L vs g/dL)
    double comparisonValue = value;
    
    // Case 1: Fraction -> Percent
    // If value is small (<= 1.5) and range is large (min > 15), assume fraction -> percent
    bool isSmallValue = value <= 1.5 && value >= 0;
    bool isLargeRange = standard.ranges.any((r) => r.minValue > 15.0);
    
    bool isFractionUnit = (currentUnit?.toLowerCase().contains('fraction') ?? false) || 
                          (currentUnit?.toLowerCase().contains('ratio') ?? false);
    
    if ((isFractionUnit || isSmallValue) && isLargeRange) {
       comparisonValue = value * 100;
       print("🔄 SMART CONVERT: $value -> $comparisonValue (Range starts > 15)");
    }
    
    // Case 2: g/L -> g/dL
    // If unit is g/L (e.g. 135) and standard is g/dL (e.g. 12-15), divide by 10
    // Check if value is large (> 50) and range is small (< 20)
    bool isGramPerLiter = (currentUnit?.toLowerCase().contains('g/l') ?? false) && 
                          !(currentUnit?.toLowerCase().contains('g/dl') ?? false);
    
    if (isGramPerLiter || (value > 50 && standard.ranges.any((r) => r.maxValue < 25))) {
       comparisonValue = value / 10;
       print("🔄 SMART CONVERT: $value g/L -> $comparisonValue g/dL");
    }

    // Find the matching range
    ReferenceRange? match;
    for (var range in standard.ranges) {
      // Check sex
      bool sexMatch = range.sex.toLowerCase() == 'any' || 
                      range.sex.toLowerCase() == sex.toLowerCase();
      
      // Check age
      bool ageMatch = age >= range.minAge && age <= range.maxAge;
      
      if (sexMatch && ageMatch) {
        match = range;
        break;
      }
    }

    if (match == null) {
      // If no specific range found, try to fall back to 'any' sex if we were specific
      try {
        match = standard.ranges.firstWhere((r) => r.sex.toLowerCase() == 'any');
      } catch (e) {
        return EvaluationResult(
          status: 'Unknown',
          rangeString: 'Range not found for profile',
          isNormal: true,
        );
      }
    }

    // Compare
    String status = 'Normal';
    bool isNormal = true;
    
    if (comparisonValue < match!.minValue) {
      status = 'Low';
      isNormal = false;
    } else if (comparisonValue > match.maxValue) {
      status = 'High';
      isNormal = false;
    }

    return EvaluationResult(
      status: status,
      rangeString: '${match.minValue} - ${match.maxValue} ${standard.unit}',
      isNormal: isNormal,
    );
  }

  /// Built-in fallback standards for common tests when Firebase doesn't have them
  MedicalStandard? _getBuiltInStandard(String testName) {
    final builtInStandards = <String, MedicalStandard>{
      'neutrophil': MedicalStandard(
        id: 'neutrophil',
        unit: '%',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 40.0, maxValue: 70.0)],
      ),
      'lymphocyte': MedicalStandard(
        id: 'lymphocyte',
        unit: '%',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 20.0, maxValue: 40.0)],
      ),
      'basophil': MedicalStandard(
        id: 'basophil',
        unit: '%',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 0.0, maxValue: 1.0)],
      ),
      'wbc': MedicalStandard(
        id: 'wbc',
        unit: '10^3/µL',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 4.5, maxValue: 11.0)],
      ),
      'platelet': MedicalStandard(
        id: 'platelet',
        unit: '10^3/µL',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 150.0, maxValue: 400.0)],
      ),
      'hematocrit': MedicalStandard(
        id: 'hematocrit',
        unit: '%',
        ranges: [
          ReferenceRange(sex: 'male', minAge: 0, maxAge: 120, minValue: 40.0, maxValue: 54.0),
          ReferenceRange(sex: 'female', minAge: 0, maxAge: 120, minValue: 36.0, maxValue: 48.0),
        ],
      ),
      'mcv': MedicalStandard(
        id: 'mcv',
        unit: 'fL',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 80.0, maxValue: 100.0)],
      ),
      'mch': MedicalStandard(
        id: 'mch',
        unit: 'pg',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 27.0, maxValue: 33.0)],
      ),
      'mchc': MedicalStandard(
        id: 'mchc',
        unit: 'g/dL',
        ranges: [ReferenceRange(sex: 'any', minAge: 0, maxAge: 120, minValue: 32.0, maxValue: 36.0)],
      ),
    };

    return builtInStandards[testName];
  }
}

class EvaluationResult {
  final String status;
  final String rangeString;
  final bool isNormal;

  EvaluationResult({
    required this.status,
    required this.rangeString,
    required this.isNormal,
  });
}

