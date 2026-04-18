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
    final path = join(dbPath, 'graamashaale.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Lessons table
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    // Questions table
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id)
      )
    ''');

    // Progress table
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

    // Doubts table
    await db.execute('''
      CREATE TABLE doubts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        question TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert dummy data
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    // Mathematics - Chapter 1
    await db.insert('lessons', {
      'subject': 'Mathematics',
      'chapter_number': 1,
      'title': 'Real Numbers',
      'content': '''Real numbers include all rational and irrational numbers.

Key Concepts:
1. Euclid\'s Division Lemma: For any two positive integers a and b, there exist unique integers q and r such that a = bq + r, where 0 ≤ r < b.

2. Fundamental Theorem of Arithmetic: Every composite number can be expressed as a product of primes in a unique way.

3. Rational Numbers: Numbers that can be expressed as p/q where q ≠ 0. Their decimal expansion is either terminating or non-terminating repeating.

4. Irrational Numbers: Numbers whose decimal expansion is non-terminating and non-repeating. Examples: √2, √3, π.

Example:
Find HCF of 96 and 404 using Euclid\'s Division Lemma.
404 = 96 × 4 + 20
96 = 20 × 4 + 16
20 = 16 × 1 + 4
16 = 4 × 4 + 0
Therefore, HCF = 4''',
    });

    // Mathematics - Chapter 2
    await db.insert('lessons', {
      'subject': 'Mathematics',
      'chapter_number': 2,
      'title': 'Polynomials',
      'content': '''A polynomial is an algebraic expression with variables and coefficients.

Key Concepts:
1. Degree of a Polynomial: The highest power of the variable.
   - Linear: degree 1 (ax + b)
   - Quadratic: degree 2 (ax² + bx + c)
   - Cubic: degree 3 (ax³ + bx² + cx + d)

2. Zeroes of a Polynomial: Values of x for which p(x) = 0.

3. For a quadratic polynomial ax² + bx + c:
   - Sum of zeroes = -b/a
   - Product of zeroes = c/a

Example:
Find zeroes of x² - 3x - 4
x² - 3x - 4 = (x-4)(x+1)
Zeroes are x = 4 and x = -1''',
    });

    // Science - Chapter 1
    await db.insert('lessons', {
      'subject': 'Science',
      'chapter_number': 1,
      'title': 'Chemical Reactions',
      'content': '''A chemical reaction is a process where substances are transformed into new substances.

Key Concepts:
1. Signs of a Chemical Reaction:
   - Change in color
   - Evolution of gas
   - Formation of precipitate
   - Change in temperature

2. Types of Chemical Reactions:
   - Combination: A + B → AB
   - Decomposition: AB → A + B
   - Displacement: A + BC → AC + B
   - Double Displacement: AB + CD → AD + CB
   - Redox: Involves oxidation and reduction

3. Balancing Chemical Equations:
   - Law of Conservation of Mass must be followed
   - Same number of atoms on both sides

Example:
Mg + O₂ → MgO (unbalanced)
2Mg + O₂ → 2MgO (balanced)''',
    });

    // Insert MCQ questions for lesson 1
    await db.insert('questions', {
      'lesson_id': 1,
      'question': 'What does Euclid\'s Division Lemma state?',
      'option_a': 'a = bq + r where 0 ≤ r < b',
      'option_b': 'a = bq + r where 0 ≤ r > b',
      'option_c': 'a = bq - r where 0 ≤ r < b',
      'option_d': 'a = bq + r where r > b',
      'correct_option': 'A',
    });

    await db.insert('questions', {
      'lesson_id': 1,
      'question': 'Which of these is an irrational number?',
      'option_a': '0.5',
      'option_b': '√4',
      'option_c': '√2',
      'option_d': '3/4',
      'correct_option': 'C',
    });

    await db.insert('questions', {
      'lesson_id': 2,
      'question': 'What is the degree of polynomial 3x² + 2x + 1?',
      'option_a': '1',
      'option_b': '2',
      'option_c': '3',
      'option_d': '0',
      'correct_option': 'B',
    });
  }
}