class Progress {
  final int? id;
  final int lessonId;
  final int score;
  final int total;
  final String attemptedAt;

  Progress({
    this.id,
    required this.lessonId,
    required this.score,
    required this.total,
    required this.attemptedAt,
  });

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'],
      lessonId: map['lesson_id'],
      score: map['score'],
      total: map['total'],
      attemptedAt: map['attempted_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'score': score,
      'total': total,
      'attempted_at': attemptedAt,
    };
  }

  double get percentage => total == 0 ? 0 : (score / total) * 100;

  String get resultLabel {
    if (percentage >= 80) return 'Excellent! 🎉';
    if (percentage >= 60) return 'Good Job! 👍';
    if (percentage >= 40) return 'Keep Practicing! 💪';
    return 'Needs Improvement 📚';
  }

  String get resultColor {
    if (percentage >= 80) return 'green';
    if (percentage >= 60) return 'blue';
    if (percentage >= 40) return 'amber';
    return 'red';
  }
}