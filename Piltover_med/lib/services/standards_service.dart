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
  }) async {
    final standard = await getStandard(testName);
    
    if (standard == null) {
      return EvaluationResult(
        status: 'Unknown',
        rangeString: 'Include reference range',
        isNormal: true, // Default to true if unknown to avoid alarm
      );
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
    
    if (value < match!.minValue) {
      status = 'Low';
      isNormal = false;
    } else if (value > match.maxValue) {
      status = 'High';
      isNormal = false;
    }

    return EvaluationResult(
      status: status,
      rangeString: '${match.minValue} - ${match.maxValue} ${standard.unit}',
      isNormal: isNormal,
    );
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

