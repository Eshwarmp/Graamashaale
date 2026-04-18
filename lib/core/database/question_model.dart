class Question {
  final int? id;
  final int lessonId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;

  Question({
    this.id,
    required this.lessonId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });

  // Convert database row to Question object
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      lessonId: map['lesson_id'],
      question: map['question'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctOption: map['correct_option'],
    );
  }

  // Convert Question object to database row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
    };
  }
}