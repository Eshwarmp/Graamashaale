class Lesson {
  final int? id;
  final String subject;
  final int chapterNumber;
  final String title;
  final String content;
  final bool isCompleted;

  Lesson({
    this.id,
    required this.subject,
    required this.chapterNumber,
    required this.title,
    required this.content,
    this.isCompleted = false,
  });

  // Convert database row to Lesson object
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      subject: map['subject'],
      chapterNumber: map['chapter_number'],
      title: map['title'],
      content: map['content'],
      isCompleted: map['is_completed'] == 1,
    );
  }

  // Convert Lesson object to database row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'chapter_number': chapterNumber,
      'title': title,
      'content': content,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}