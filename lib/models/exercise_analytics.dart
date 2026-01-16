class ExerciseAnalytics {
  final double averageScore;
  final List<ExerciseData> data;

  ExerciseAnalytics({
    required this.averageScore,
    required this.data,
  });

  factory ExerciseAnalytics.fromJson(Map<String, dynamic> json) {
    return ExerciseAnalytics(
      averageScore: (json['average_score'] as num).toDouble(),
      data: (json['data'] as List<dynamic>)
          .map((item) => ExerciseData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExerciseData {
  final String name;
  final double score;
  final String date;

  ExerciseData({
    required this.name,
    required this.score,
    required this.date,
  });

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    return ExerciseData(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
      date: json['date'] as String,
    );
  }
}
