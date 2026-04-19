class Lesson {
  final int? id;
  final String subject;
  final int part;
  final String title;
  final String pdfPath;
  final int classLevel;
  final bool isCompleted;

  Lesson({
    this.id,
    required this.subject,
    required this.part,
    required this.title,
    required this.pdfPath,
    required this.classLevel,
    this.isCompleted = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      subject: map['subject'],
      part: map['part'],
      title: map['title'],
      pdfPath: map['pdf_path'],
      classLevel: map['class_level'],
      isCompleted: map['is_completed'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'part': part,
      'title': title,
      'pdf_path': pdfPath,
      'class_level': classLevel,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}