import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'graamashaale_v4.db');
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
        pdf_path TEXT NOT NULL,
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
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await _insertLessons(db);
    await _insertQuestions(db);
  }

  Future<void> _insertLessons(Database db) async {
    final subjects = [
      // CLASS 8
      // Core
      {'subject': 'Mathematics', 'part': 1, 'title': 'Mathematics Part 1', 'pdf_path': 'assets/content/class8/core/maths1.pdf', 'class_level': 8},
      {'subject': 'Mathematics', 'part': 2, 'title': 'Mathematics Part 2', 'pdf_path': 'assets/content/class8/core/maths2.pdf', 'class_level': 8},
      {'subject': 'Science', 'part': 1, 'title': 'Science Part 1', 'pdf_path': 'assets/content/class8/core/science1.pdf', 'class_level': 8},
      {'subject': 'Science', 'part': 2, 'title': 'Science Part 2', 'pdf_path': 'assets/content/class8/core/science2.pdf', 'class_level': 8},
      {'subject': 'Social Studies', 'part': 1, 'title': 'Social Studies Part 1', 'pdf_path': 'assets/content/class8/core/social1.pdf', 'class_level': 8},
      {'subject': 'Social Studies', 'part': 2, 'title': 'Social Studies Part 2', 'pdf_path': 'assets/content/class8/core/social2.pdf', 'class_level': 8},
      // Languages
      {'subject': 'English', 'part': 1, 'title': 'English Part 1', 'pdf_path': 'assets/content/class8/languages/english1.pdf', 'class_level': 8},
      {'subject': 'English', 'part': 2, 'title': 'English Part 2', 'pdf_path': 'assets/content/class8/languages/english2.pdf', 'class_level': 8},
      {'subject': 'Kannada', 'part': 1, 'title': 'Kannada Part 1', 'pdf_path': 'assets/content/class8/languages/kannada1.pdf', 'class_level': 8},
      {'subject': 'Kannada', 'part': 2, 'title': 'Kannada Part 2', 'pdf_path': 'assets/content/class8/languages/kannada2.pdf', 'class_level': 8},
      {'subject': 'Hindi', 'part': 1, 'title': 'Hindi Part 1', 'pdf_path': 'assets/content/class8/languages/hindi1.pdf', 'class_level': 8},
      {'subject': 'Hindi', 'part': 2, 'title': 'Hindi Part 2', 'pdf_path': 'assets/content/class8/languages/hindi2.pdf', 'class_level': 8},

      // CLASS 9
      {'subject': 'Mathematics', 'part': 1, 'title': 'Mathematics Part 1', 'pdf_path': 'assets/content/class9/core/maths1.pdf', 'class_level': 9},
      {'subject': 'Mathematics', 'part': 2, 'title': 'Mathematics Part 2', 'pdf_path': 'assets/content/class9/core/maths2.pdf', 'class_level': 9},
      {'subject': 'Science', 'part': 1, 'title': 'Science Part 1', 'pdf_path': 'assets/content/class9/core/science1.pdf', 'class_level': 9},
      {'subject': 'Science', 'part': 2, 'title': 'Science Part 2', 'pdf_path': 'assets/content/class9/core/science2.pdf', 'class_level': 9},
      {'subject': 'Social Studies', 'part': 1, 'title': 'Social Studies Part 1', 'pdf_path': 'assets/content/class9/core/social1.pdf', 'class_level': 9},
      {'subject': 'Social Studies', 'part': 2, 'title': 'Social Studies Part 2', 'pdf_path': 'assets/content/class9/core/social2.pdf', 'class_level': 9},
      {'subject': 'English', 'part': 1, 'title': 'English Part 1', 'pdf_path': 'assets/content/class9/languages/english1.pdf', 'class_level': 9},
      {'subject': 'English', 'part': 2, 'title': 'English Part 2', 'pdf_path': 'assets/content/class9/languages/english2.pdf', 'class_level': 9},
      {'subject': 'Kannada', 'part': 1, 'title': 'Kannada Part 1', 'pdf_path': 'assets/content/class9/languages/kannada1.pdf', 'class_level': 9},
      {'subject': 'Kannada', 'part': 2, 'title': 'Kannada Part 2', 'pdf_path': 'assets/content/class9/languages/kannada2.pdf', 'class_level': 9},
      {'subject': 'Hindi', 'part': 1, 'title': 'Hindi Part 1', 'pdf_path': 'assets/content/class9/languages/hindi1.pdf', 'class_level': 9},
      {'subject': 'Hindi', 'part': 2, 'title': 'Hindi Part 2', 'pdf_path': 'assets/content/class9/languages/hindi2.pdf', 'class_level': 9},

      // CLASS 10
      {'subject': 'Mathematics', 'part': 1, 'title': 'Mathematics Part 1', 'pdf_path': 'assets/content/class10/core/maths1.pdf', 'class_level': 10},
      {'subject': 'Mathematics', 'part': 2, 'title': 'Mathematics Part 2', 'pdf_path': 'assets/content/class10/core/maths2.pdf', 'class_level': 10},
      {'subject': 'Science', 'part': 1, 'title': 'Science Part 1', 'pdf_path': 'assets/content/class10/core/science1.pdf', 'class_level': 10},
      {'subject': 'Science', 'part': 2, 'title': 'Science Part 2', 'pdf_path': 'assets/content/class10/core/science2.pdf', 'class_level': 10},
      {'subject': 'Social Studies', 'part': 1, 'title': 'Social Studies Part 1', 'pdf_path': 'assets/content/class10/core/social1.pdf', 'class_level': 10},
      {'subject': 'Social Studies', 'part': 2, 'title': 'Social Studies Part 2', 'pdf_path': 'assets/content/class10/core/social2.pdf', 'class_level': 10},
      {'subject': 'English', 'part': 1, 'title': 'English Part 1', 'pdf_path': 'assets/content/class10/languages/english1.pdf', 'class_level': 10},
      {'subject': 'English', 'part': 2, 'title': 'English Part 2', 'pdf_path': 'assets/content/class10/languages/english2.pdf', 'class_level': 10},
      {'subject': 'Kannada', 'part': 1, 'title': 'Kannada Part 1', 'pdf_path': 'assets/content/class10/languages/kannada1.pdf', 'class_level': 10},
      {'subject': 'Kannada', 'part': 2, 'title': 'Kannada Part 2', 'pdf_path': 'assets/content/class10/languages/kannada2.pdf', 'class_level': 10},
      {'subject': 'Hindi', 'part': 1, 'title': 'Hindi Part 1', 'pdf_path': 'assets/content/class10/languages/hindi1.pdf', 'class_level': 10},
      {'subject': 'Hindi', 'part': 2, 'title': 'Hindi Part 2', 'pdf_path': 'assets/content/class10/languages/hindi2.pdf', 'class_level': 10},
    ];

    for (final s in subjects) {
      await db.insert('lessons', {
        'subject': s['subject'],
        'part': s['part'],
        'title': s['title'],
        'pdf_path': s['pdf_path'],
        'class_level': s['class_level'],
        'is_completed': 0,
      });
    }
  }

  Future<void> _insertQuestions(Database db) async {
    // Mathematics Class 8
    await _addQ(db, 1, 'What is a rational number?', 'ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ ಎಂದರೇನು?', 'p/q where q≠0', 'p+q', 'p×q', 'p-q', 'A');
    await _addQ(db, 1, 'Which property: a+b = b+a?', 'a+b = b+a ಯಾವ ಗುಣ?', 'Associative', 'Commutative', 'Distributive', 'Closure', 'B');

    // Science Class 8
    await _addQ(db, 3, 'Kharif crops are grown in?', 'ಖಾರಿಫ್ ಬೆಳೆ ಯಾವ ಋತುವಿನಲ್ಲಿ?', 'Oct-Mar', 'June-Sep', 'Mar-June', 'Dec-Feb', 'B');
    await _addQ(db, 3, 'Which fixes nitrogen in soil?', 'ಮಣ್ಣಿನಲ್ಲಿ ಸಾರಜನಕ ಸ್ಥಿರೀಕರಿಸುವ ಬ್ಯಾಕ್ಟೀರಿಯಾ?', 'Lactobacillus', 'Rhizobium', 'Penicillium', 'Yeast', 'B');

    // Mathematics Class 9
    await _addQ(db, 13, 'Which is irrational?', 'ಅಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ ಯಾವುದು?', '√4', '√9', '√2', '0.5', 'C');
    await _addQ(db, 13, 'a⁰ = ?', 'a⁰ = ?', '0', 'a', '1', 'Undefined', 'C');

    // Science Class 9
    await _addQ(db, 15, 'Boiling point of water?', 'ನೀರಿನ ಕುದಿಯುವ ಬಿಂದು?', '0°C', '50°C', '100°C', '200°C', 'C');
    await _addQ(db, 15, 'Sublimation example?', 'ಉತ್ಪತನಕ್ಕೆ ಉದಾಹರಣೆ?', 'Ice', 'Water', 'Camphor', 'Salt', 'C');

    // Mathematics Class 10
    await _addQ(db, 25, 'Euclid\'s Lemma: a =', 'ಯೂಕ್ಲಿಡ್ ಲೆಮ್ಮಾ: a =', 'bq+r, 0≤r<b', 'bq-r', 'bq+r, r>b', 'bq×r', 'A');
    await _addQ(db, 25, 'HCF × LCM =', 'ಮ.ಸಾ.ಅ × ಲ.ಸಾ.ಅ =', 'Sum', 'Difference', 'Product', 'Square', 'C');

    // Science Class 10
    await _addQ(db, 27, 'Combination reaction:', 'ಸಂಯೋಜನ ಕ್ರಿಯೆ:', 'AB→A+B', 'A+B→AB', 'A+BC→AC+B', 'AB+CD→AD+CB', 'B');
    await _addQ(db, 27, 'Oxidation =', 'ಆಕ್ಸಿಡೀಕರಣ =', 'Gain electrons', 'Loss electrons', 'Gain protons', 'Loss neutrons', 'B');
  }

  Future<void> _addQ(Database db, int lessonId,
      String qEn, String qKn,
      String a, String b, String c, String d, String correct) async {
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