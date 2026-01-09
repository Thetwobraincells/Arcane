// This file defines the structure of the data coming from Firebase

class ReferenceRange {
  final String sex;       // e.g., 'male', 'female'
  final int minAge;       // e.g., 18
  final int maxAge;       // e.g., 100
  final double minValue;  // e.g., 13.5
  final double maxValue;  // e.g., 17.5

  ReferenceRange({
    required this.sex,
    required this.minAge,
    required this.maxAge,
    required this.minValue,
    required this.maxValue,
  });

  // Convert JSON (Map) from Firebase into this Dart object
  factory ReferenceRange.fromMap(Map<String, dynamic> map) {
    return ReferenceRange(
      sex: map['sex'] ?? 'any',
      minAge: (map['min_age'] ?? 0).toInt(),
      maxAge: (map['max_age'] ?? 120).toInt(),
      // Handle cases where numbers might be integers in the DB but we need doubles
      minValue: (map['min_value'] ?? 0).toDouble(),
      maxValue: (map['max_value'] ?? 0).toDouble(),
    );
  }
}

class MedicalStandard {
  final String id;        // e.g., 'hemoglobin'
  final String unit;      // e.g., 'g/dL'
  final List<ReferenceRange> ranges;

  MedicalStandard({
    required this.id,
    required this.unit,
    required this.ranges,
  });

  // Convert the entire Firestore document into this Dart object
  factory MedicalStandard.fromSnapshot(String id, Map<String, dynamic> map) {
    return MedicalStandard(
      id: id,
      unit: map['unit'] ?? '',
      ranges: (map['ranges'] as List<dynamic>?)
              ?.map((x) => ReferenceRange.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
