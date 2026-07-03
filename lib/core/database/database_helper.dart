import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static const String _baseUrl =
      'https://github.com/Eshwarmp/Graamashaale/releases/download/v1.0-pdfs/';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'graamashaale_v12.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        part INTEGER NOT NULL,
        title TEXT NOT NULL,
        pdf_path_en TEXT NOT NULL,
        pdf_path_kn TEXT NOT NULL,
        class_level INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        question_english TEXT NOT NULL,
        question_kannada TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        student_id TEXT NOT NULL DEFAULT '',
        score INTEGER DEFAULT 0,
        total INTEGER DEFAULT 0,
        attempted_at TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE doubts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT,
        student_name TEXT,
        student_class TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        student_id TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE progress_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        progress_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        question_english TEXT NOT NULL,
        question_kannada TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        selected_option TEXT NOT NULL,
        is_correct INTEGER NOT NULL
      )
    ''');

    await _insertLessons(db);
    await _insertQuestions(db);
  }

  Future<void> _insertLessons(Database db) async {
    // ── CLASS 8 ──────────────────────────────────────────
    await _addLesson(db, 'Mathematics', 1, 'Mathematics Part 1', 8,
        '${_baseUrl}class8_core_maths1.pdf',
        '${_baseUrl}class8_core_maths1_kn.pdf');
    await _addLesson(db, 'Mathematics', 2, 'Mathematics Part 2', 8,
        '${_baseUrl}class8_core_maths2.pdf',
        '${_baseUrl}class8_core_maths2_kn.pdf');
    await _addLesson(db, 'Science', 1, 'Science Part 1', 8,
        '${_baseUrl}class8_core_science1.pdf',
        '${_baseUrl}class8_core_science1_kn.pdf');
    await _addLesson(db, 'Science', 2, 'Science Part 2', 8,
        '${_baseUrl}class8_core_science2.pdf',
        '${_baseUrl}class8_core_science2_kn.pdf');
    await _addLesson(db, 'Social Studies', 1, 'Social Studies Part 1', 8,
        '${_baseUrl}class8_core_social1.pdf',
        '${_baseUrl}class8_core_social1_kn.pdf');
    await _addLesson(db, 'Social Studies', 2, 'Social Studies Part 2', 8,
        '${_baseUrl}class8_core_social2.pdf',
        '${_baseUrl}class8_core_social2_kn.pdf');
    await _addLesson(db, 'English', 1, 'English Part 1', 8,
        '${_baseUrl}class8_lang_english1.pdf',
        '${_baseUrl}class8_lang_english1.pdf');
    await _addLesson(db, 'English', 2, 'English Part 2', 8,
        '${_baseUrl}class8_lang_english2.pdf',
        '${_baseUrl}class8_lang_english2.pdf');
    await _addLesson(db, 'Kannada', 1, 'Kannada Part 1', 8,
        '${_baseUrl}class8_lang_kannada1.pdf',
        '${_baseUrl}class8_lang_kannada1.pdf');
    await _addLesson(db, 'Kannada', 2, 'Kannada Part 2', 8,
        '${_baseUrl}class8_lang_kannada2.pdf',
        '${_baseUrl}class8_lang_kannada2.pdf');
    await _addLesson(db, 'Hindi', 1, 'Hindi Part 1', 8,
        '${_baseUrl}class8_lang_hindi1.pdf',
        '${_baseUrl}class8_lang_hindi1.pdf');
    await _addLesson(db, 'Hindi', 2, 'Hindi Part 2', 8,
        '${_baseUrl}class8_lang_hindi2.pdf',
        '${_baseUrl}class8_lang_hindi2.pdf');

    // ── CLASS 9 ──────────────────────────────────────────
    await _addLesson(db, 'Mathematics', 1, 'Mathematics Part 1', 9,
        '${_baseUrl}class9_core_maths1.pdf',
        '${_baseUrl}class9_core_maths1_kn.pdf');
    await _addLesson(db, 'Mathematics', 2, 'Mathematics Part 2', 9,
        '${_baseUrl}class9_core_maths2.pdf',
        '${_baseUrl}class9_core_maths2_kn.pdf');
    await _addLesson(db, 'Science', 1, 'Science Part 1', 9,
        '${_baseUrl}class9_core_science1.pdf',
        '${_baseUrl}class9_core_science1_kn.pdf');
    await _addLesson(db, 'Science', 2, 'Science Part 2', 9,
        '${_baseUrl}class9_core_science2.pdf',
        '${_baseUrl}class9_core_science2_kn.pdf');
    await _addLesson(db, 'Social Studies', 1, 'Social Studies Part 1', 9,
        '${_baseUrl}class9_core_social1.pdf',
        '${_baseUrl}class9_core_social1_kn.pdf');
    await _addLesson(db, 'Social Studies', 2, 'Social Studies Part 2', 9,
        '${_baseUrl}class9_core_social2.pdf',
        '${_baseUrl}class9_core_social2_kn.pdf');
    await _addLesson(db, 'English', 1, 'English Part 1', 9,
        '${_baseUrl}class9_lang_english1.pdf',
        '${_baseUrl}class9_lang_english1.pdf');
    await _addLesson(db, 'English', 2, 'English Part 2', 9,
        '${_baseUrl}class9_lang_english2.pdf',
        '${_baseUrl}class9_lang_english2.pdf');
    await _addLesson(db, 'Kannada', 1, 'Kannada Part 1', 9,
        '${_baseUrl}class9_lang_kannada1.pdf',
        '${_baseUrl}class9_lang_kannada1.pdf');
    await _addLesson(db, 'Kannada', 2, 'Kannada Part 2', 9,
        '${_baseUrl}class9_lang_kannada2.pdf',
        '${_baseUrl}class9_lang_kannada2.pdf');
    await _addLesson(db, 'Hindi', 1, 'Hindi Part 1', 9,
        '${_baseUrl}class9_lang_hindi1.pdf',
        '${_baseUrl}class9_lang_hindi1.pdf');
    await _addLesson(db, 'Hindi', 2, 'Hindi Part 2', 9,
        '${_baseUrl}class9_lang_hindi2.pdf',
        '${_baseUrl}class9_lang_hindi2.pdf');

    // ── CLASS 10 ─────────────────────────────────────────
    await _addLesson(db, 'Mathematics', 1, 'Mathematics Part 1', 10,
        '${_baseUrl}class10_core_maths1.pdf',
        '${_baseUrl}class10_core_maths1_kn.pdf');
    await _addLesson(db, 'Mathematics', 2, 'Mathematics Part 2', 10,
        '${_baseUrl}class10_core_maths2.pdf',
        '${_baseUrl}class10_core_maths2_kn.pdf');
    await _addLesson(db, 'Science', 1, 'Science Part 1', 10,
        '${_baseUrl}class10_core_science1.pdf',
        '${_baseUrl}class10_core_science1_kn.pdf');
    await _addLesson(db, 'Science', 2, 'Science Part 2', 10,
        '${_baseUrl}class10_core_science2.pdf',
        '${_baseUrl}class10_core_science2_kn.pdf');
    await _addLesson(db, 'Social Studies', 1, 'Social Studies Part 1', 10,
        '${_baseUrl}class10_core_social1.pdf',
        '${_baseUrl}class10_core_social1_kn.pdf');
    await _addLesson(db, 'Social Studies', 2, 'Social Studies Part 2', 10,
        '${_baseUrl}class10_core_social2.pdf',
        '${_baseUrl}class10_core_social2_kn.pdf');
    await _addLesson(db, 'English', 1, 'English Part 1', 10,
        '${_baseUrl}class10_lang_english1.pdf',
        '${_baseUrl}class10_lang_english1.pdf');
    await _addLesson(db, 'English', 2, 'English Part 2', 10,
        '${_baseUrl}class10_lang_english2.pdf',
        '${_baseUrl}class10_lang_english2.pdf');
    await _addLesson(db, 'Kannada', 1, 'Kannada Part 1', 10,
        '${_baseUrl}class10_lang_kannada1.pdf',
        '${_baseUrl}class10_lang_kannada1.pdf');
    await _addLesson(db, 'Kannada', 2, 'Kannada Part 2', 10,
        '${_baseUrl}class10_lang_kannda2.pdf',
        '${_baseUrl}class10_lang_kannda2.pdf');
    await _addLesson(db, 'Hindi', 1, 'Hindi Part 1', 10,
        '${_baseUrl}class10_lang_hindi1.pdf',
        '${_baseUrl}class10_lang_hindi1.pdf');
    await _addLesson(db, 'Hindi', 2, 'Hindi Part 2', 10,
        '${_baseUrl}class10_lang_hindi2.pdf',
        '${_baseUrl}class10_lang_hindi2.pdf');
  }

  Future<void> _insertQuestions(Database db) async {
    // Mathematics Class 8 — lesson id 1
    await _addQ(db, 1,
        'What is a rational number?',
        'ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ ಎಂದರೇನು?',
        'p/q where q≠0', 'p+q', 'p×q', 'p-q', 'A');
    await _addQ(db, 1,
        'Which property: a+b = b+a?',
        'a+b = b+a ಯಾವ ಗುಣ?',
        'Associative', 'Commutative', 'Distributive', 'Closure', 'B');

    // Science Class 8 — lesson id 3
    await _addQ(db, 3,
        'Kharif crops are grown in?',
        'ಖಾರಿಫ್ ಬೆಳೆ ಯಾವ ಋತುವಿನಲ್ಲಿ?',
        'Oct-Mar', 'June-Sep', 'Mar-June', 'Dec-Feb', 'B');
    await _addQ(db, 3,
        'Which fixes nitrogen in soil?',
        'ಮಣ್ಣಿನಲ್ಲಿ ಸಾರಜನಕ ಸ್ಥಿರೀಕರಿಸುವ ಬ್ಯಾಕ್ಟೀರಿಯಾ?',
        'Lactobacillus', 'Rhizobium', 'Penicillium', 'Yeast', 'B');

    // Mathematics Class 9 — lesson id 13
    await _addQ(db, 13,
        'Which is irrational?',
        'ಅಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ ಯಾವುದು?',
        '√4', '√9', '√2', '0.5', 'C');
    await _addQ(db, 13,
        'a⁰ = ?', 'a⁰ = ?',
        '0', 'a', '1', 'Undefined', 'C');

    // Science Class 9 — lesson id 15
    await _addQ(db, 15,
        'Boiling point of water?',
        'ನೀರಿನ ಕುದಿಯುವ ಬಿಂದು?',
        '0°C', '50°C', '100°C', '200°C', 'C');
    await _addQ(db, 15,
        'Sublimation example?',
        'ಉತ್ಪತನಕ್ಕೆ ಉದಾಹರಣೆ?',
        'Ice', 'Water', 'Camphor', 'Salt', 'C');

    // Mathematics Class 10 — lesson id 25
    await _addQ(db, 25,
        'Euclid\'s Lemma: a =',
        'ಯೂಕ್ಲಿಡ್ ಲೆಮ್ಮಾ: a =',
        'bq+r, 0≤r<b', 'bq-r', 'bq+r, r>b', 'bq×r', 'A');
    await _addQ(db, 25,
        'HCF × LCM =',
        'ಮ.ಸಾ.ಅ × ಲ.ಸಾ.ಅ =',
        'Sum', 'Difference', 'Product', 'Square', 'C');

    // Science Class 10 — lesson id 27
    await _addQ(db, 27,
        'Combination reaction:',
        'ಸಂಯೋಜನ ಕ್ರಿಯೆ:',
        'AB→A+B', 'A+B→AB', 'A+BC→AC+B', 'AB+CD→AD+CB', 'B');
    await _addQ(db, 27,
        'Oxidation =',
        'ಆಕ್ಸಿಡೀಕರಣ =',
        'Gain electrons', 'Loss electrons',
        'Gain protons', 'Loss neutrons', 'B');
  }

  Future<void> _addLesson(Database db, String subject, int part,
      String title, int classLevel,
      String pdfPathEn, String pdfPathKn) async {
    await db.insert('lessons', {
      'subject': subject,
      'part': part,
      'title': title,
      'pdf_path_en': pdfPathEn,
      'pdf_path_kn': pdfPathKn,
      'class_level': classLevel,
      'is_completed': 0,
    });
  }

  Future<void> _addQ(Database db, int lessonId,
      String qEn, String qKn,
      String a, String b, String c, String d,
      String correct) async {
    await db.insert('questions', {
      'lesson_id': lessonId,
      'question_english': qEn,
      'question_kannada': qKn,
      'option_a': a,
      'option_b': b,
      'option_c': c,
      'option_d': d,
      'correct_option': correct,
    });
  }
}