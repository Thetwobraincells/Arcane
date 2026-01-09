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
}
