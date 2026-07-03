class Announcement {
  final String? id;
  final String title;
  final String message;
  final String teacherName;
  final String subject;
  final String createdAt;

  Announcement({
    this.id,
    required this.title,
    required this.message,
    required this.teacherName,
    required this.subject,
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String id) {
    return Announcement(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      teacherName: map['teacher_name'] ?? '',
      subject: map['subject'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'teacher_name': teacherName,
      'subject': subject,
      'created_at': createdAt,
    };
  }
}