import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';
import 'lesson_model.dart';
import 'question_model.dart';
import 'progress_model.dart';
import 'doubt_model.dart';

class DatabaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get current student ID
  Future<String> _getStudentId() async {
    final box = await Hive.openBox('settings');
    return box.get('student_id', defaultValue: 'default');
  }

  // ─── LESSONS ───────────────────────────────────────────

  Future<List<Lesson>> getLessonsBySubject(
      String subject, int classLevel) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    final maps = await db.query(
      'lessons',
      where: 'subject = ? AND class_level = ?',
      whereArgs: [subject, classLevel],
      orderBy: 'part ASC',
    );

    // Check completion per student
    final lessons = await Future.wait(maps.map((map) async {
      final completions = await db.query(
        'completions',
        where: 'lesson_id = ? AND student_id = ?',
        whereArgs: [map['id'], studentId],
      );
      return Lesson.fromMap({
        ...map,
        'is_completed': completions.isNotEmpty ? 1 : 0,
      });
    }));

    return lessons;
  }

  Future<Lesson?> getLessonById(int id) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    final maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final completions = await db.query(
      'completions',
      where: 'lesson_id = ? AND student_id = ?',
      whereArgs: [id, studentId],
    );

    return Lesson.fromMap({
      ...maps.first,
      'is_completed': completions.isNotEmpty ? 1 : 0,
    });
  }

  Future<void> markLessonCompleted(int lessonId) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();

    // Check if already completed
    final existing = await db.query(
      'completions',
      where: 'lesson_id = ? AND student_id = ?',
      whereArgs: [lessonId, studentId],
    );

    if (existing.isEmpty) {
      await db.insert('completions', {
        'lesson_id': lessonId,
        'student_id': studentId,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int> getCompletedCount(String subject) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();

    // Get all lesson IDs for this subject
    final lessons = await db.query(
      'lessons',
      columns: ['id'],
      where: 'subject = ?',
      whereArgs: [subject],
    );

    if (lessons.isEmpty) return 0;

    final lessonIds = lessons.map((l) => l['id']).toList();
    final placeholders = lessonIds.map((_) => '?').join(',');

    final completions = await db.rawQuery(
      'SELECT COUNT(*) as count FROM completions WHERE student_id = ? AND lesson_id IN ($placeholders)',
      [studentId, ...lessonIds],
    );

    return (completions.first['count'] as int?) ?? 0;
  }

  // Get completed count across ALL students (for teacher view)
Future<int> getCompletedCountAllStudents(String subject) async {
  final db = await _dbHelper.database;
  final lessons = await db.query(
    'lessons',
    columns: ['id'],
    where: 'subject = ?',
    whereArgs: [subject],
  );
  if (lessons.isEmpty) return 0;
  final lessonIds = lessons.map((l) => l['id']).toList();
  final placeholders = lessonIds.map((_) => '?').join(',');
  final completions = await db.rawQuery(
    'SELECT COUNT(*) as count FROM completions WHERE lesson_id IN ($placeholders)',
    [...lessonIds],
  );
  return (completions.first['count'] as int?) ?? 0;
}

  Future<int> getTotalCount(String subject, int classLevel) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'lessons',
      where: 'subject = ? AND class_level = ?',
      whereArgs: [subject, classLevel],
    );
    return result.length;
  }

  // ─── QUESTIONS ─────────────────────────────────────────

  Future<List<Question>> getQuestionsByLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return maps.map((map) => Question.fromMap(map)).toList();
  }

  Future<bool> hasAiQuestions(int lessonId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return result.length >= 5;
  }

  Future<void> saveAiQuestions(
      int lessonId, List<Map<String, dynamic>> questions) async {
    final db = await _dbHelper.database;
    await db.delete(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    for (final q in questions) {
      await db.insert('questions', {
        'lesson_id': lessonId,
        'question_english': q['question_english'],
        'question_kannada': q['question_kannada'],
        'option_a': q['option_a'],
        'option_b': q['option_b'],
        'option_c': q['option_c'],
        'option_d': q['option_d'],
        'correct_option': q['correct_option'],
      });
    }
  }

  Future<void> deleteQuestions(int lessonId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
  }

  // ─── PROGRESS ──────────────────────────────────────────

  Future<void> saveProgress(Progress progress) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    await db.insert('progress', {
      ...progress.toMap(),
      'student_id': studentId,
    });
  }

  Future<List<Progress>> getAllProgress() async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    final maps = await db.query(
      'progress',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'attempted_at DESC',
    );
    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  // Get all progress across ALL students (for teacher view)
Future<List<Progress>> getAllProgressAllStudents() async {
  final db = await _dbHelper.database;
  final maps = await db.query(
    'progress',
    orderBy: 'attempted_at DESC',
  );
  return maps.map((map) => Progress.fromMap(map)).toList();
}

  Future<List<Progress>> getProgressByLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    final maps = await db.query(
      'progress',
      where: 'lesson_id = ? AND student_id = ?',
      whereArgs: [lessonId, studentId],
      orderBy: 'attempted_at DESC',
    );
    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  Future<Progress?> getBestScore(int lessonId) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    final maps = await db.query(
      'progress',
      where: 'lesson_id = ? AND student_id = ?',
      whereArgs: [lessonId, studentId],
      orderBy: 'score DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Progress.fromMap(maps.first);
  }

  // ─── DOUBTS ────────────────────────────────────────────

  Future<void> saveDoubt(Doubt doubt) async {
    final db = await _dbHelper.database;
    await db.insert('doubts', doubt.toMap());
  }

  Future<List<Doubt>> getUnsyncedDoubts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'doubts',
      where: 'is_synced = 0',
    );
    return maps.map((map) => Doubt.fromMap(map)).toList();
  }

  Future<List<Doubt>> getAllDoubts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'doubts',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Doubt.fromMap(map)).toList();
  }

  Future<List<Doubt>> getDoubtsByStudent(String studentName) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'doubts',
      where: 'student_name = ?',
      whereArgs: [studentName],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Doubt.fromMap(map)).toList();
  }

  Future<List<Doubt>> getDoubtsBySubject(String subject) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'doubts',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Doubt.fromMap(map)).toList();
  }

  Future<void> markDoubtSynced(int doubtId) async {
    final db = await _dbHelper.database;
    await db.update(
      'doubts',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [doubtId],
    );
  }

  Future<void> answerDoubt(int doubtId, String answer) async {
    final db = await _dbHelper.database;
    await db.update(
      'doubts',
      {'answer': answer, 'is_synced': 1},
      where: 'id = ?',
      whereArgs: [doubtId],
    );
  }

  // ─── STREAK ────────────────────────────────────────────

  Future<void> updateStreak() async {
    final box = await Hive.openBox('settings');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastStudy = box.get('last_study_date', defaultValue: '');
    int streak = box.get('streak', defaultValue: 0);

    if (lastStudy == today) return;

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    streak = (lastStudy == yesterday) ? streak + 1 : 1;

    await box.put('last_study_date', today);
    await box.put('streak', streak);
  }

  Future<int> getStreak() async {
    final box = await Hive.openBox('settings');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastStudy = box.get('last_study_date', defaultValue: '');
    final streak = box.get('streak', defaultValue: 0);

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    if (lastStudy == today || lastStudy == yesterday) return streak;
    return 0;
  }

  Future<int> saveProgressWithId(Progress progress) async {
    final db = await _dbHelper.database;
    final studentId = await _getStudentId();
    return await db.insert('progress', {
      ...progress.toMap(),
      'student_id': studentId,
    });
  }

  Future<void> saveProgressAnswers(int progressId, List<Map<String, dynamic>> answers) async {
    final db = await _dbHelper.database;
    for (final a in answers) {
      await db.insert('progress_answers', {
        'progress_id': progressId,
        'question_id': a['question_id'],
        'question_english': a['question_english'],
        'question_kannada': a['question_kannada'],
        'option_a': a['option_a'],
        'option_b': a['option_b'],
        'option_c': a['option_c'],
        'option_d': a['option_d'],
        'correct_option': a['correct_option'],
        'selected_option': a['selected_option'],
        'is_correct': a['is_correct'] ? 1 : 0,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getProgressAnswers(int progressId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'progress_answers',
      where: 'progress_id = ?',
      whereArgs: [progressId],
    );
  }
}