import 'database_helper.dart';
import 'lesson_model.dart';
import 'question_model.dart';
import 'progress_model.dart';
import 'doubt_model.dart';

class DatabaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ─── LESSONS ───────────────────────────────────────────

  // Get lessons by subject and class level
  Future<List<Lesson>> getLessonsBySubject(
      String subject, int classLevel) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'lessons',
      where: 'subject = ? AND class_level = ?',
      whereArgs: [subject, classLevel],
      orderBy: 'part ASC',
    );
    return maps.map((map) => Lesson.fromMap(map)).toList();
  }

  // Get a single lesson by id
  Future<Lesson?> getLessonById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Lesson.fromMap(maps.first);
  }

  // Mark lesson as completed
  Future<void> markLessonCompleted(int lessonId) async {
    final db = await _dbHelper.database;
    await db.update(
      'lessons',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }

  // Get completed lessons count for a subject
  Future<int> getCompletedCount(String subject) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'lessons',
      where: 'subject = ? AND is_completed = 1',
      whereArgs: [subject],
    );
    return result.length;
  }

  // Get total lessons count for a subject and class
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

  // Get all questions for a lesson
  Future<List<Question>> getQuestionsByLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return maps.map((map) => Question.fromMap(map)).toList();
  }

  // ─── PROGRESS ──────────────────────────────────────────

  // Save quiz result
  Future<void> saveProgress(Progress progress) async {
    final db = await _dbHelper.database;
    await db.insert('progress', progress.toMap());
  }

  // Get all progress records
  Future<List<Progress>> getAllProgress() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'progress',
      orderBy: 'attempted_at DESC',
    );
    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  // Get progress for a specific lesson
  Future<List<Progress>> getProgressByLesson(int lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'progress',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'attempted_at DESC',
    );
    return maps.map((map) => Progress.fromMap(map)).toList();
  }

  // Get best score for a lesson
  Future<Progress?> getBestScore(int lessonId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'progress',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'score DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Progress.fromMap(maps.first);
  }

  // ─── DOUBTS ────────────────────────────────────────────

  // Save a new doubt
  Future<void> saveDoubt(Doubt doubt) async {
    final db = await _dbHelper.database;
    await db.insert('doubts', doubt.toMap());
  }

  // Get all unsynced doubts
  Future<List<Doubt>> getUnsyncedDoubts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'doubts',
      where: 'is_synced = 0',
    );
    return maps.map((map) => Doubt.fromMap(map)).toList();
  }

  // Get all doubts
  Future<List<Doubt>> getAllDoubts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'doubts',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Doubt.fromMap(map)).toList();
  }

  // Mark doubt as synced
  Future<void> markDoubtSynced(int doubtId) async {
    final db = await _dbHelper.database;
    await db.update(
      'doubts',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [doubtId],
    );
  }

  // Save teacher's answer to a doubt
  Future<void> answerDoubt(int doubtId, String answer) async {
    final db = await _dbHelper.database;
    await db.update(
      'doubts',
      {
        'answer': answer,
        'is_synced': 1,
      },
      where: 'id = ?',
      whereArgs: [doubtId],
    );
  }
}