class Question {
  final int? id;
  final int lessonId;
  final String questionEnglish;
  final String questionKannada;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;

  Question({
    this.id,
    required this.lessonId,
    required this.questionEnglish,
    required this.questionKannada,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      lessonId: map['lesson_id'],
      questionEnglish: map['question_english'],
      questionKannada: map['question_kannada'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctOption: map['correct_option'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question_english': questionEnglish,
      'question_kannada': questionKannada,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
    };
  }

  // Get question based on medium
  String getQuestion(String medium) {
    return medium == 'kannada' ? questionKannada : questionEnglish;
  }
}