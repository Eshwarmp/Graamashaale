class Doubt {
  final int? id;
  final String subject;
  final String question;
  final bool isSynced;
  final String createdAt;

  Doubt({
    this.id,
    required this.subject,
    required this.question,
    this.isSynced = false,
    required this.createdAt,
  });

  factory Doubt.fromMap(Map<String, dynamic> map) {
    return Doubt(
      id: map['id'],
      subject: map['subject'],
      question: map['question'],
      isSynced: map['is_synced'] == 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'question': question,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt,
    };
  }
}