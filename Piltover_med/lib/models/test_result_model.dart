class TestResult {
  final String testName;
  final String value;
  final String unit;
  final String status; // 'normal', 'high', 'low', 'critical'
  final DateTime date;

  TestResult({
    required this.testName,
    required this.value,
    required this.unit,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'testName': testName,
        'value': value,
        'unit': unit,
        'status': status,
        'date': date.toIso8601String(),
      };

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
        testName: json['testName'] as String,
        value: json['value'] as String,
        unit: json['unit'] as String,
        status: json['status'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

