class WorkoutSession {
  final DateTime date;
  final String title;
  final int durationMinutes;
  final int totalReps;
  final int formScorePercent;
  final Map<String, double> breakdown;

  WorkoutSession({
    required this.date,
    required this.title,
    required this.durationMinutes,
    required this.totalReps,
    required this.formScorePercent,
    required this.breakdown,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? 'Workout Session',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      totalReps: (json['totalReps'] as num?)?.toInt() ?? 0,
      formScorePercent: (json['formScorePercent'] as num?)?.toInt() ?? 0,
      breakdown: json['breakdown'] is Map
          ? (json['breakdown'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble()))
          : <String, double>{},
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'title': title,
        'durationMinutes': durationMinutes,
        'totalReps': totalReps,
        'formScorePercent': formScorePercent,
        'breakdown': breakdown,
      };
}