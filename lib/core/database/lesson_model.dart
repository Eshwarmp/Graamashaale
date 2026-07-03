class Lesson {
  final int? id;
  final String subject;
  final int part;
  final String title;
  final String pdfPathEn;
  final String pdfPathKn;
  final int classLevel;
  final bool isCompleted;

  Lesson({
    this.id,
    required this.subject,
    required this.part,
    required this.title,
    required this.pdfPathEn,
    required this.pdfPathKn,
    required this.classLevel,
    this.isCompleted = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      subject: map['subject'],
      part: map['part'],
      title: map['title'],
      pdfPathEn: map['pdf_path_en'],
      pdfPathKn: map['pdf_path_kn'],
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
      'pdf_path_en': pdfPathEn,
      'pdf_path_kn': pdfPathKn,
      'class_level': classLevel,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  // Get correct PDF path based on medium
  String getPdfPath(String medium) {
    return medium == 'kannada' ? pdfPathKn : pdfPathEn;
  }
}