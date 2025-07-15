// lib/models/test_result.dart
class TestResult {
  final String id;
  final String testId;
  final String patientId;
  final DateTime takenAt;
  final String severityLevel;
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;
  final String recommendationOverview;

  TestResult({
    required this.id,
    required this.testId,
    required this.patientId,
    required this.takenAt,
    required this.severityLevel,
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
    required this.recommendationOverview,
  });

  factory TestResult.fromJson(Map<String, dynamic> j) {
    return TestResult(
      id: j['id'] as String,
      testId: j['testId'] as String,
      patientId: j['patientId'] as String,
      takenAt: DateTime.parse(j['takenAt'] as String),
      severityLevel: j['severityLevel'] as String,
      depressionScore: j['depressionScore']['value'] as int,
      anxietyScore: j['anxietyScore']['value'] as int,
      stressScore: j['stressScore']['value'] as int,
      recommendationOverview: j['recommendation']['overview'] as String,
    );
  }
}
