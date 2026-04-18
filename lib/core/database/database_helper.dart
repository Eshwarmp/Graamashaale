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
    final path = join(dbPath, 'graamashaale_v3.db');
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
        chapter_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        content_english TEXT NOT NULL,
        content_kannada TEXT NOT NULL,
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

    await _insertData(db);
  }

  Future<void> _insertData(Database db) async {

    // ── CLASS 8 ──────────────────────────────────────────

    await _insertLesson(db, 'Mathematics', 1, 'Rational Numbers', 8,
      '''Rational Numbers

A rational number is expressed as p/q where p and q are integers and q ≠ 0.

Properties:
- Closure: Sum/product of two rational numbers is rational
- Commutative: a+b = b+a
- Associative: (a+b)+c = a+(b+c)
- Distributive: a×(b+c) = a×b + a×c

Between any two rational numbers, there are infinitely many rational numbers.

Example:
Find rational numbers between 1/3 and 1/2
1/3 = 4/12 and 1/2 = 6/12
So 5/12 lies between them.''',

      '''ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಗಳು

ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಯನ್ನು p/q ರೂಪದಲ್ಲಿ ಬರೆಯಬಹುದು, ಇಲ್ಲಿ q ≠ 0.

ಗುಣಗಳು:
- ಸಂವರಣ: ಎರಡು ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಗಳ ಮೊತ್ತ/ಗುಣಲಬ್ಧ ಭಾಗಲಬ್ಧ
- ವಿನಿಮಯ: a+b = b+a
- ಸಹಚರ: (a+b)+c = a+(b+c)
- ವಿತರಣ: a×(b+c) = a×b + a×c

ಯಾವುದೇ ಎರಡು ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಗಳ ನಡುವೆ ಅನಂತ ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಗಳಿವೆ.

ಉದಾಹರಣೆ:
1/3 ಮತ್ತು 1/2 ನಡುವೆ ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ ಹುಡುಕಿ
1/3 = 4/12 ಮತ್ತು 1/2 = 6/12
ಆದ್ದರಿಂದ 5/12 ನಡುವೆ ಇದೆ.''');

    await _insertLesson(db, 'Mathematics', 2, 'Linear Equations', 8,
      '''Linear Equations in One Variable

A linear equation: ax + b = 0

Solving:
- Transpose terms to opposite sides
- Perform same operation on both sides

Example:
Solve: 2x + 5 = 11
2x = 11 - 5 = 6
x = 3

Word Problem:
Sum of two consecutive numbers is 25.
Let numbers be x and x+1
x + x+1 = 25 → x = 12
Numbers are 12 and 13.''',

      '''ಒಂದು ಚರದಲ್ಲಿ ರೇಖೀಯ ಸಮೀಕರಣ

ರೇಖೀಯ ಸಮೀಕರಣ: ax + b = 0

ಪರಿಹಾರ:
- ಪದಗಳನ್ನು ಸ್ಥಳಾಂತರಿಸಿ
- ಎರಡೂ ಬದಿಗೆ ಒಂದೇ ಕ್ರಿಯೆ ಮಾಡಿ

ಉದಾಹರಣೆ:
2x + 5 = 11 ಪರಿಹರಿಸಿ
2x = 6
x = 3

ಪದ ಸಮಸ್ಯೆ:
ಎರಡು ಅನುಕ್ರಮ ಸಂಖ್ಯೆಗಳ ಮೊತ್ತ 25.
x ಮತ್ತು x+1 ಎಂದಿಟ್ಟುಕೊಂಡರೆ
x = 12, ಸಂಖ್ಯೆಗಳು 12 ಮತ್ತು 13.''');

    await _insertLesson(db, 'Science', 1, 'Crop Production', 8,
      '''Crop Production and Management

Types of Crops:
- Kharif (June-Sep): Paddy, Maize, Cotton
- Rabi (Oct-Mar): Wheat, Gram, Mustard
- Zaid (Mar-June): Watermelon, Cucumber

Agricultural Practices:
1. Soil Preparation: Ploughing and leveling
2. Sowing: Using quality seeds
3. Irrigation: Regular water supply
4. Weeding: Removing unwanted plants
5. Harvesting: Cutting mature crops
6. Storage: Preventing damage''',

      '''ಬೆಳೆ ಉತ್ಪಾದನೆ ಮತ್ತು ನಿರ್ವಹಣೆ

ಬೆಳೆಗಳ ವಿಧಗಳು:
- ಖಾರಿಫ್ (ಜೂನ್-ಸೆಪ್ಟೆಂ): ಭತ್ತ, ಜೋಳ, ಹತ್ತಿ
- ರಬಿ (ಅಕ್ಟೋ-ಮಾರ್ಚ್): ಗೋಧಿ, ಕಡಲೆ, ಸಾಸಿವೆ
- ಜಾಯಿದ್ (ಮಾರ್ಚ್-ಜೂನ್): ಕಲ್ಲಂಗಡಿ, ಸೌತೆ

ಕೃಷಿ ಚಟುವಟಿಕೆಗಳು:
1. ಮಣ್ಣು ತಯಾರಿ: ಉಳುಮೆ ಮತ್ತು ಸಮತಟ್ಟು
2. ಬಿತ್ತನೆ: ಗುಣಮಟ್ಟದ ಬೀಜ ಬಳಕೆ
3. ನೀರಾವರಿ: ನಿಯಮಿತ ನೀರು ಪೂರೈಕೆ
4. ಕಳೆ ತೆಗೆಯುವಿಕೆ: ಅನಗತ್ಯ ಗಿಡ ತೆಗೆಯುವುದು
5. ಕೊಯ್ಲು: ಮಾಗಿದ ಬೆಳೆ ಕಟಾವು
6. ಸಂಗ್ರಹಣೆ: ಹಾನಿ ತಡೆಗಟ್ಟುವುದು''');

    await _insertLesson(db, 'Social Studies', 1, 'How When and Where', 8,
      '''How, When and Where

History helps us understand the past.

Periodisation:
- Ancient period
- Medieval period  
- Modern period (British rule in India)

Colonial Records:
- British kept detailed records
- Surveys collected systematic data
- Census operations began

Important Terms:
- Colonialism: Control of one country over another
- Survey: Systematic data collection
- Archives: Document storage places''',

      '''ಹೇಗೆ, ಯಾವಾಗ ಮತ್ತು ಎಲ್ಲಿ

ಇತಿಹಾಸ ನಮಗೆ ಹಿಂದಿನ ಕಾಲವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.

ಕಾಲ ವಿಭಾಗ:
- ಪ್ರಾಚೀನ ಕಾಲ
- ಮಧ್ಯಕಾಲ
- ಆಧುನಿಕ ಕಾಲ (ಬ್ರಿಟಿಷ್ ಆಳ್ವಿಕೆ)

ವಸಾಹತುಶಾಹಿ ದಾಖಲೆಗಳು:
- ಬ್ರಿಟಿಷರು ವಿಸ್ತೃತ ದಾಖಲೆಗಳನ್ನು ಇಟ್ಟರು
- ಸಮೀಕ್ಷೆಗಳು ವ್ಯವಸ್ಥಿತ ಮಾಹಿತಿ ಸಂಗ್ರಹಿಸಿದವು

ಪ್ರಮುಖ ಪದಗಳು:
- ವಸಾಹತುಶಾಹಿ: ಒಂದು ದೇಶದ ಮೇಲೆ ಮತ್ತೊಂದರ ನಿಯಂತ್ರಣ
- ಸಮೀಕ್ಷೆ: ವ್ಯವಸ್ಥಿತ ಮಾಹಿತಿ ಸಂಗ್ರಹ
- ಪುರಾಲೇಖನ: ದಾಖಲೆ ಸಂಗ್ರಹ ಸ್ಥಳ''');

    await _insertLesson(db, 'English', 1, 'The Best Christmas Present', 8,
      '''The Best Christmas Present in the World

Summary:
- Jim Macpherson wrote a letter to his wife Connie
- Written on Christmas Day 1914 during World War I
- German and British soldiers stopped fighting for one day
- They played football together in No Man\'s Land

Themes:
1. Peace and Humanity
2. Love and Hope

Vocabulary:
- Truce: Agreement to stop fighting
- Dugout: Underground soldier shelter
- Extraordinary: Very unusual''',

      '''ಜಗತ್ತಿನ ಅತ್ಯುತ್ತಮ ಕ್ರಿಸ್ಮಸ್ ಉಡುಗೊರೆ

ಸಾರಾಂಶ:
- ಜಿಮ್ ಮ್ಯಾಕ್ಫರ್ಸನ್ ಪತ್ನಿ ಕಾನಿಗೆ ಪತ್ರ ಬರೆದ
- 1914ರ ಕ್ರಿಸ್ಮಸ್ ದಿನ ಮೊದಲ ವಿಶ್ವಯುದ್ಧದಲ್ಲಿ ಬರೆದದ್ದು
- ಜರ್ಮನ್ ಮತ್ತು ಬ್ರಿಟಿಷ್ ಸೈನಿಕರು ಒಂದು ದಿನ ಯುದ್ಧ ನಿಲ್ಲಿಸಿದರು
- ಅವರು ಫುಟ್ಬಾಲ್ ಆಡಿದರು

ವಿಷಯಗಳು:
1. ಶಾಂತಿ ಮತ್ತು ಮಾನವೀಯತೆ
2. ಪ್ರೀತಿ ಮತ್ತು ಭರವಸೆ

ಶಬ್ದ ಭಂಡಾರ:
- Truce: ಯುದ್ಧ ವಿರಾಮ ಒಪ್ಪಂದ
- Dugout: ಭೂಗತ ಸೈನಿಕ ಆಶ್ರಯ''');

    await _insertLesson(db, 'Kannada', 1, 'ಭಾರತ ಭೂಮಿ', 8,
      '''Bharata Bhoomi (Land of India)

This poem describes the beauty and greatness of India.

Key Points:
- India is a land of unity in diversity
- Extends from Himalayas to Kanyakumari
- Land of rivers: Ganga, Yamuna, Kaveri
- Land of many languages, cultures and religions

Grammar:
- Noun: Name of person, place, thing
- Verb: Word showing action
- Adjective: Word describing a noun

New Words:
- ವಿಶಾಲ = Vast
- ಸಮೃದ್ಧ = Prosperous
- ಪವಿತ್ರ = Sacred''',

      '''ಭಾರತ ಭೂಮಿ

ಈ ಪದ್ಯದಲ್ಲಿ ಭಾರತ ದೇಶದ ಪ್ರಕೃತಿ ಸೌಂದರ್ಯ ವರ್ಣಿಸಲಾಗಿದೆ.

ಮುಖ್ಯ ಅಂಶಗಳು:
- ಭಾರತ ವಿವಿಧತೆಯಲ್ಲಿ ಏಕತೆಯ ದೇಶ
- ಹಿಮಾಲಯದಿಂದ ಕನ್ಯಾಕುಮಾರಿವರೆಗೆ ವಿಸ್ತರಿಸಿದೆ
- ಗಂಗಾ, ಯಮುನಾ, ಕಾವೇರಿ ನದಿಗಳ ನಾಡು
- ಅನೇಕ ಭಾಷೆ, ಸಂಸ್ಕೃತಿ, ಧರ್ಮಗಳ ನಾಡು

ವ್ಯಾಕರಣ:
- ನಾಮಪದ: ವ್ಯಕ್ತಿ, ಸ್ಥಳ, ವಸ್ತುವಿನ ಹೆಸರು
- ಕ್ರಿಯಾಪದ: ಕ್ರಿಯೆ ತೋರಿಸುವ ಪದ
- ವಿಶೇಷಣ: ನಾಮಪದ ವಿಶೇಷಿಸುವ ಪದ

ಹೊಸ ಪದಗಳು:
- ವಿಶಾಲ = ದೊಡ್ಡದು
- ಸಮೃದ್ಧ = ಸಂಪದ್ಭರಿತ
- ಪವಿತ್ರ = ಶುದ್ಧ''');

    // ── CLASS 9 ──────────────────────────────────────────

    await _insertLesson(db, 'Mathematics', 1, 'Number Systems', 9,
      '''Number Systems

Types:
- Natural Numbers (N): 1, 2, 3...
- Whole Numbers (W): 0, 1, 2, 3...
- Integers (Z): ...-2, -1, 0, 1, 2...
- Rational Numbers (Q): p/q form, q≠0
- Irrational Numbers: √2, √3, π
- Real Numbers (R): All rational + irrational

Laws of Exponents:
- aᵐ × aⁿ = aᵐ⁺ⁿ
- aᵐ ÷ aⁿ = aᵐ⁻ⁿ
- (aᵐ)ⁿ = aᵐⁿ
- a⁰ = 1

Rationalising: 1/√2 × √2/√2 = √2/2''',

      '''ಸಂಖ್ಯಾ ವ್ಯವಸ್ಥೆ

ವಿಧಗಳು:
- ನೈಸರ್ಗಿಕ ಸಂಖ್ಯೆ (N): 1, 2, 3...
- ಪೂರ್ಣ ಸಂಖ್ಯೆ (W): 0, 1, 2, 3...
- ಪೂರ್ಣಾಂಕ (Z): ...-2, -1, 0, 1, 2...
- ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ (Q): p/q ರೂಪ, q≠0
- ಅಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ: √2, √3, π
- ವಾಸ್ತವ ಸಂಖ್ಯೆ (R): ಭಾಗಲಬ್ಧ + ಅಭಾಗಲಬ್ಧ

ಘಾತಾಂಕ ನಿಯಮಗಳು:
- aᵐ × aⁿ = aᵐ⁺ⁿ
- aᵐ ÷ aⁿ = aᵐ⁻ⁿ
- (aᵐ)ⁿ = aᵐⁿ
- a⁰ = 1''');

    await _insertLesson(db, 'Mathematics', 2, 'Polynomials', 9,
      '''Polynomials

Types:
- Monomial: One term (3x)
- Binomial: Two terms (x+2)
- Trinomial: Three terms (x²+2x+1)

Theorems:
- Remainder Theorem: If p(x) divided by (x-a), remainder = p(a)
- Factor Theorem: (x-a) is factor if p(a) = 0

Identities:
- (a+b)² = a² + 2ab + b²
- (a-b)² = a² - 2ab + b²
- (a+b)(a-b) = a² - b²''',

      '''ಬಹುಪದೋಕ್ತಿಗಳು

ವಿಧಗಳು:
- ಏಕಪದ: ಒಂದು ಪದ (3x)
- ದ್ವಿಪದ: ಎರಡು ಪದ (x+2)
- ತ್ರಿಪದ: ಮೂರು ಪದ (x²+2x+1)

ಪ್ರಮೇಯಗಳು:
- ಶೇಷ ಪ್ರಮೇಯ: p(x) ಅನ್ನು (x-a) ನಿಂದ ಭಾಗಿಸಿದರೆ ಶೇಷ = p(a)
- ಅಪವರ್ತ ಪ್ರಮೇಯ: p(a) = 0 ಆದರೆ (x-a) ಅಪವರ್ತ

ಸರ್ವಸಮೀಕರಣಗಳು:
- (a+b)² = a² + 2ab + b²
- (a-b)² = a² - 2ab + b²
- (a+b)(a-b) = a² - b²''');

    await _insertLesson(db, 'Science', 1, 'Matter in Our Surroundings', 9,
      '''Matter in Our Surroundings

States of Matter:
1. Solid: Definite shape and volume
2. Liquid: Definite volume, no definite shape
3. Gas: No definite shape or volume

Changes of State:
- Melting: Solid → Liquid
- Freezing: Liquid → Solid
- Evaporation: Liquid → Gas
- Condensation: Gas → Liquid
- Sublimation: Solid → Gas (camphor, dry ice)

Key Facts:
- Boiling point of water = 100°C
- Melting point of ice = 0°C
- Evaporation causes cooling''',

      '''ನಮ್ಮ ಸುತ್ತಲಿನ ವಸ್ತು

ವಸ್ತುವಿನ ಸ್ಥಿತಿಗಳು:
1. ಘನ: ನಿಶ್ಚಿತ ಆಕಾರ ಮತ್ತು ಗಾತ್ರ
2. ದ್ರವ: ನಿಶ್ಚಿತ ಗಾತ್ರ, ಆಕಾರವಿಲ್ಲ
3. ಅನಿಲ: ಆಕಾರ ಮತ್ತು ಗಾತ್ರವಿಲ್ಲ

ಸ್ಥಿತಿ ಬದಲಾವಣೆ:
- ಕರಗುವಿಕೆ: ಘನ → ದ್ರವ
- ಹೆಪ್ಪುಗಟ್ಟುವಿಕೆ: ದ್ರವ → ಘನ
- ಆವಿಯಾಗುವಿಕೆ: ದ್ರವ → ಅನಿಲ
- ಘನೀಭವನ: ಅನಿಲ → ದ್ರವ
- ಉತ್ಪತನ: ಘನ → ಅನಿಲ (ಕರ್ಪೂರ)

ಪ್ರಮುಖ ಸಂಗತಿಗಳು:
- ನೀರಿನ ಕುದಿಯುವ ಬಿಂದು = 100°C
- ಮಂಜುಗಡ್ಡೆಯ ಕರಗುವ ಬಿಂದು = 0°C''');

    await _insertLesson(db, 'Social Studies', 1, 'The French Revolution', 9,
      '''The French Revolution (1789)

Causes:
1. Financial Crisis
2. Social Inequality (Three Estates)
3. Influence of philosophers
4. Food scarcity
5. Weak leadership

Three Estates:
- First: Clergy
- Second: Nobility
- Third: Common people (paid all taxes)

Key Events:
- July 14, 1789: Storming of Bastille
- Declaration of Rights of Man
- Execution of King Louis XVI
- Rise of Napoleon

Impact:
- Ideas of Liberty, Equality, Fraternity spread worldwide''',

      '''ಫ್ರೆಂಚ್ ಕ್ರಾಂತಿ (1789)

ಕಾರಣಗಳು:
1. ಆರ್ಥಿಕ ಬಿಕ್ಕಟ್ಟು
2. ಸಾಮಾಜಿಕ ಅಸಮಾನತೆ
3. ತತ್ವಜ್ಞಾನಿಗಳ ಪ್ರಭಾವ
4. ಆಹಾರ ಕೊರತೆ
5. ದುರ್ಬಲ ನಾಯಕತ್ವ

ಮೂರು ವರ್ಗಗಳು:
- ಮೊದಲನೆಯದು: ಪಾದ್ರಿಗಳು
- ಎರಡನೆಯದು: ಶ್ರೀಮಂತರು
- ಮೂರನೆಯದು: ಸಾಮಾನ್ಯ ಜನರು (ತೆರಿಗೆ ಕಟ್ಟುತ್ತಿದ್ದರು)

ಪ್ರಮುಖ ಘಟನೆಗಳು:
- ಜುಲೈ 14, 1789: ಬಾಸ್ಟಿಲ್ ಮೇಲೆ ದಾಳಿ
- ಮಾನವ ಹಕ್ಕುಗಳ ಘೋಷಣೆ
- ಲೂಯಿ XVI ಮರಣದಂಡನೆ

ಪ್ರಭಾವ:
- ಸ್ವಾತಂತ್ರ್ಯ, ಸಮಾನತೆ, ಭ್ರಾತೃತ್ವ ವಿಶ್ವಾದ್ಯಂತ ಹರಡಿತು''');

    await _insertLesson(db, 'English', 1, 'The Fun They Had', 9,
      '''The Fun They Had — Isaac Asimov

Set in 2157 AD.

Summary:
- Margie and Tommy find an old printed book
- In their time, schools are mechanical robots
- Margie\'s teacher was giving her bad scores
- Inspector adjusts the mechanical teacher
- Margie imagines old schools with real teachers

Themes:
1. Technology vs Human Touch
2. Importance of social interaction
3. Nostalgia for traditional education

Vocabulary:
- Mechanical: Operated by machine
- Scornful: Showing contempt
- Loftily: In a superior manner''',

      '''ಅವರಿಗಿದ್ದ ಮೋಜು — ಐಸಾಕ್ ಅಸಿಮೊವ್

2157 ADನಲ್ಲಿ ನಡೆಯುವ ಕಥೆ.

ಸಾರಾಂಶ:
- ಮಾರ್ಗಿ ಮತ್ತು ಟಾಮಿ ಹಳೆಯ ಮುದ್ರಿತ ಪುಸ್ತಕ ಕಂಡುಕೊಳ್ಳುತ್ತಾರೆ
- ಅವರ ಕಾಲದಲ್ಲಿ ಶಾಲೆಗಳು ಯಂತ್ರ ರೂಪದಲ್ಲಿವೆ
- ಮಾರ್ಗಿಯ ಶಿಕ್ಷಕ ಯಂತ್ರ ಕೆಟ್ಟ ಅಂಕ ಕೊಡುತ್ತಿತ್ತು
- ತಂತ್ರಜ್ಞ ಯಂತ್ರ ಸರಿಪಡಿಸುತ್ತಾನೆ
- ಮಾರ್ಗಿ ಹಳೆಯ ಶಾಲೆಗಳ ಬಗ್ಗೆ ಕನಸು ಕಾಣುತ್ತಾಳೆ

ವಿಷಯಗಳು:
1. ತಂತ್ರಜ್ಞಾನ ವಿರುದ್ಧ ಮಾನವ ಸ್ಪರ್ಶ
2. ಸಾಮಾಜಿಕ ಒಡನಾಟದ ಮಹತ್ವ''');

    await _insertLesson(db, 'Kannada', 1, 'ಕನ್ನಡ ನಾಡು', 9,
      '''Karnataka State (Kannada Nadu)

Introduction:
- State: Karnataka
- Capital: Bengaluru
- Language: Kannada
- State festival: Rajyotsava (Nov 1)

Major Rivers:
- Kaveri, Krishna, Tungabhadra, Sharavathi

Famous Personalities:
- Kuvempu — Rashtra Kavi
- Basavanna — Social reformer
- Tipu Sultan — Tiger of Mysore

Grammar (Sandhi):
- Svara Sandhi: Two vowels joining
- Vyanjana Sandhi: Consonant + vowel joining''',

      '''ಕನ್ನಡ ನಾಡು

ಪರಿಚಯ:
- ರಾಜ್ಯ: ಕರ್ನಾಟಕ
- ರಾಜಧಾನಿ: ಬೆಂಗಳೂರು
- ಭಾಷೆ: ಕನ್ನಡ
- ರಾಜ್ಯ ಹಬ್ಬ: ರಾಜ್ಯೋತ್ಸವ (ನವೆಂಬರ್ 1)

ಪ್ರಮುಖ ನದಿಗಳು:
- ಕಾವೇರಿ, ಕೃಷ್ಣಾ, ತುಂಗಭದ್ರಾ, ಶರಾವತಿ

ಪ್ರಮುಖ ವ್ಯಕ್ತಿಗಳು:
- ಕುವೆಂಪು — ರಾಷ್ಟ್ರಕವಿ
- ಬಸವಣ್ಣ — ಸಮಾಜ ಸುಧಾರಕ
- ಟಿಪ್ಪು ಸುಲ್ತಾನ್ — ಮೈಸೂರು ಹುಲಿ

ವ್ಯಾಕರಣ (ಸಂಧಿ):
- ಸ್ವರ ಸಂಧಿ: ಎರಡು ಸ್ವರಗಳ ಸೇರ್ಪಡೆ
- ವ್ಯಂಜನ ಸಂಧಿ: ವ್ಯಂಜನ + ಸ್ವರ ಸೇರ್ಪಡೆ''');

    // ── CLASS 10 ─────────────────────────────────────────

    await _insertLesson(db, 'Mathematics', 1, 'Real Numbers', 10,
      '''Real Numbers

1. Euclid\'s Division Lemma:
   a = bq + r, where 0 ≤ r < b

2. Fundamental Theorem of Arithmetic:
   Every composite number = unique product of primes

3. HCF × LCM = Product of two numbers

4. Irrational Numbers: √2, √3, √5

5. Decimal Expansions:
   • Terminating: q = 2ⁿ × 5ᵐ
   • Non-terminating repeating: rational
   • Non-terminating non-repeating: irrational

Example:
HCF(96, 404):
404 = 96×4+20, 96 = 20×4+16
20 = 16×1+4, 16 = 4×4+0
HCF = 4''',

      '''ವಾಸ್ತವ ಸಂಖ್ಯೆಗಳು

1. ಯೂಕ್ಲಿಡ್ ಭಾಗಾಕಾರ ಲೆಮ್ಮಾ:
   a = bq + r, ಇಲ್ಲಿ 0 ≤ r < b

2. ಅಂಕಗಣಿತದ ಮೂಲಭೂತ ಪ್ರಮೇಯ:
   ಪ್ರತಿ ಸಂಯುಕ್ತ ಸಂಖ್ಯೆ = ಅವಿಭಾಜ್ಯ ಸಂಖ್ಯೆಗಳ ಗುಣಲಬ್ಧ

3. ಮ.ಸಾ.ಅ × ಲ.ಸಾ.ಅ = ಎರಡು ಸಂಖ್ಯೆಗಳ ಗುಣಲಬ್ಧ

4. ಅಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಗಳು: √2, √3, √5

5. ದಶಮಾಂಶ ವಿಸ್ತರಣೆ:
   • ಸಾಂತ: q = 2ⁿ × 5ᵐ
   • ಅಸಾಂತ ಆವರ್ತಿ: ಭಾಗಲಬ್ಧ
   • ಅಸಾಂತ ಅನಾವರ್ತಿ: ಅಭಾಗಲಬ್ಧ''');

    await _insertLesson(db, 'Mathematics', 2, 'Polynomials', 10,
      '''Polynomials — Class 10

For quadratic ax² + bx + c:
- Sum of zeroes (α+β) = -b/a
- Product of zeroes (αβ) = c/a

For cubic ax³ + bx² + cx + d:
- α+β+γ = -b/a
- αβ+βγ+γα = c/a
- αβγ = -d/a

Division Algorithm:
p(x) = g(x) × q(x) + r(x)

Example:
Zeroes of x² - 3x - 4:
(x-4)(x+1) = 0
x = 4 and x = -1
Sum = 3 = -(-3)/1 ✓
Product = -4 = -4/1 ✓''',

      '''ಬಹುಪದೋಕ್ತಿಗಳು — 10ನೇ ತರಗತಿ

ದ್ವಿಘಾತ ax² + bx + c ಗೆ:
- ಶೂನ್ಯಗಳ ಮೊತ್ತ (α+β) = -b/a
- ಶೂನ್ಯಗಳ ಗುಣಲಬ್ಧ (αβ) = c/a

ತ್ರಿಘಾತ ax³ + bx² + cx + d ಗೆ:
- α+β+γ = -b/a
- αβ+βγ+γα = c/a
- αβγ = -d/a

ಭಾಗಾಕಾರ ಅಲ್ಗಾರಿದಮ್:
p(x) = g(x) × q(x) + r(x)

ಉದಾಹರಣೆ:
x² - 3x - 4 ರ ಶೂನ್ಯಗಳು:
x = 4 ಮತ್ತು x = -1''');

    await _insertLesson(db, 'Science', 1, 'Chemical Reactions', 10,
      '''Chemical Reactions and Equations

Signs of Chemical Reaction:
- Change in colour
- Gas evolution
- Precipitate formation
- Temperature change

Types:
1. Combination: A+B → AB (2H₂+O₂ → 2H₂O)
2. Decomposition: AB → A+B
3. Displacement: Fe+CuSO₄ → FeSO₄+Cu
4. Double Displacement: NaCl+AgNO₃ → AgCl+NaNO₃
5. Redox: Oxidation + Reduction

Balancing:
2Mg + O₂ → 2MgO ✓''',

      '''ರಾಸಾಯನಿಕ ಕ್ರಿಯೆಗಳು ಮತ್ತು ಸಮೀಕರಣಗಳು

ರಾಸಾಯನಿಕ ಕ್ರಿಯೆಯ ಚಿಹ್ನೆಗಳು:
- ಬಣ್ಣ ಬದಲಾವಣೆ
- ಅನಿಲ ಬಿಡುಗಡೆ
- ಅವಕ್ಷೇಪ ರಚನೆ
- ತಾಪಮಾನ ಬದಲಾವಣೆ

ವಿಧಗಳು:
1. ಸಂಯೋಜನೆ: A+B → AB
2. ವಿಭಜನೆ: AB → A+B
3. ಸ್ಥಾನಪಲ್ಲಟ: Fe+CuSO₄ → FeSO₄+Cu
4. ದ್ವಿ ಸ್ಥಾನಪಲ್ಲಟ
5. ರೆಡಾಕ್ಸ್: ಆಕ್ಸಿಡೀಕರಣ + ಅಪಕರಣ

ಸಮತೋಲನ:
2Mg + O₂ → 2MgO ✓''');

    await _insertLesson(db, 'Social Studies', 1, 'Nationalism in Europe', 10,
      '''The Rise of Nationalism in Europe

Key Concepts:
1. French Revolution spread nationalism
2. Middle class demanded nation-states

Unification of Germany (1866-71):
- Bismarck — "blood and iron" policy
- Defeated Austria and France
- German Empire in 1871

Unification of Italy:
- Mazzini — Young Italy movement
- Cavour — diplomacy
- Garibaldi — military
- United Italy by 1861

Symbols:
- Germania — German nation
- Marianne — French Republic''',

      '''ಯೂರೋಪಿನಲ್ಲಿ ರಾಷ್ಟ್ರೀಯತೆಯ ಉದಯ

ಪ್ರಮುಖ ವಿಚಾರಗಳು:
1. ಫ್ರೆಂಚ್ ಕ್ರಾಂತಿ ರಾಷ್ಟ್ರೀಯತೆ ಹರಡಿತು
2. ಮಧ್ಯಮ ವರ್ಗ ರಾಷ್ಟ್ರ-ರಾಜ್ಯ ಬೇಡಿಕೊಂಡಿತು

ಜರ್ಮನಿ ಏಕೀಕರಣ (1866-71):
- ಬಿಸ್ಮಾರ್ಕ್ — "ರಕ್ತ ಮತ್ತು ಕಬ್ಬಿಣ" ನೀತಿ
- ಆಸ್ಟ್ರಿಯಾ ಮತ್ತು ಫ್ರಾನ್ಸ್ ಸೋಲಿಸಿದ
- 1871ರಲ್ಲಿ ಜರ್ಮನ್ ಸಾಮ್ರಾಜ್ಯ

ಇಟಲಿ ಏಕೀಕರಣ:
- ಮಾಝಿನಿ — ಯಂಗ್ ಇಟಲಿ ಚಳವಳಿ
- ಕಾವೂರ್ — ರಾಜತಾಂತ್ರಿಕತೆ
- ಗ್ಯಾರಿಬಾಲ್ಡಿ — ಸೇನಾ ಕಾರ್ಯಾಚರಣೆ''');

    await _insertLesson(db, 'English', 1, 'A Letter to God', 10,
      '''A Letter to God — G.L. Fuentes

Summary:
- Lencho is a farmer whose crops are destroyed by hailstorm
- He writes a letter to God asking for 100 pesos
- Postmaster collects 70 pesos and sends it
- Lencho gets money but is angry — thinks post office stole 30 pesos
- He writes another letter calling them "bad people"

Themes:
1. Unshakeable Faith in God
2. Irony
3. Human Goodness

Vocabulary:
- Intimately: In a close manner
- Plague: Calamity
- Amiable: Friendly''',

      '''ದೇವರಿಗೊಂದು ಪತ್ರ — G.L. ಫ್ಯೂಯೆಂಟ್ಸ್

ಸಾರಾಂಶ:
- ಲೆಂಕೋ ರೈತನ ಬೆಳೆ ಆಲಿಕಲ್ಲು ಮಳೆಯಿಂದ ನಾಶ
- ಅವನು ದೇವರಿಗೆ 100 ಪೆಸೊ ಕೇಳಿ ಪತ್ರ ಬರೆದ
- ಅಂಚೆ ಮುಖ್ಯಸ್ಥ 70 ಪೆಸೊ ಕಳಿಸಿದ
- ಲೆಂಕೋ ಹಣ ಪಡೆದರೂ ಕೋಪಗೊಂಡ
- 30 ಪೆಸೊ ಕದ್ದರು ಎಂದು ಭಾವಿಸಿ ಮತ್ತೊಂದು ಪತ್ರ ಬರೆದ

ವಿಷಯಗಳು:
1. ದೇವರಲ್ಲಿ ಅಚಲ ನಂಬಿಕೆ
2. ವ್ಯಂಗ್ಯ
3. ಮಾನವ ಒಳ್ಳೆಯತನ''');

    await _insertLesson(db, 'Kannada', 1, 'ಚೇತನದ ಬೆಳಕು', 10,
      '''Chetanada Belaku (Light of Consciousness)

Summary:
This lesson talks about values of human life.

Key Ideas:
1. Education is like light
2. Knowledge is power
3. Service is the goal of life

Grammar:
- Samasa (Compound words):
  - Tatpurusha Samasa
  - Karmadharaya Samasa
  - Dvandva Samasa
- Alankara (Figures of Speech):
  - Upama (Simile)
  - Rupaka (Metaphor)

About Author:
Kuvempu — Rashtra Kavi, great Kannada poet''',

      '''ಚೇತನದ ಬೆಳಕು

ಸಾರಾಂಶ:
ಈ ಪಾಠ ಮಾನವ ಜೀವನದ ಮೌಲ್ಯಗಳ ಬಗ್ಗೆ ತಿಳಿಸುತ್ತದೆ.

ಮುಖ್ಯ ವಿಚಾರಗಳು:
1. ಶಿಕ್ಷಣ ಬೆಳಕಿನಂತೆ
2. ಜ್ಞಾನವೇ ಶಕ್ತಿ
3. ಸೇವೆಯೇ ಜೀವನದ ಗುರಿ

ವ್ಯಾಕರಣ:
- ಸಮಾಸ:
  - ತತ್ಪುರುಷ ಸಮಾಸ
  - ಕರ್ಮಧಾರಯ ಸಮಾಸ
  - ದ್ವಂದ್ವ ಸಮಾಸ
- ಅಲಂಕಾರ:
  - ಉಪಮಾ: ಹೋಲಿಕೆ
  - ರೂಪಕ: ನೇರ ಹೋಲಿಕೆ

ಕವಿ ಪರಿಚಯ:
ಕುವೆಂಪು — ರಾಷ್ಟ್ರಕವಿ''');

    // ── MCQ QUESTIONS ────────────────────────────────────

    await _insertQuestion(db, 1,
      'Which property states a+b = b+a?',
      'a+b = b+a ಎಂಬ ಗುಣ ಯಾವುದು?',
      'Associative', 'Commutative', 'Distributive', 'Closure', 'B');

    await _insertQuestion(db, 1,
      'Between two rational numbers there are:',
      'ಎರಡು ಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆಗಳ ನಡುವೆ ಎಷ್ಟು ಸಂಖ್ಯೆಗಳಿವೆ?',
      'No numbers', 'Finite numbers', 'Infinitely many', 'Only integers', 'C');

    await _insertQuestion(db, 7,
      'Which of these is irrational?',
      'ಇವುಗಳಲ್ಲಿ ಅಭಾಗಲಬ್ಧ ಸಂಖ್ಯೆ ಯಾವುದು?',
      '√4', '√9', '√2', '0.5', 'C');

    await _insertQuestion(db, 7,
      'What is a⁰ equal to?',
      'a⁰ ಎಷ್ಟಕ್ಕೆ ಸಮ?',
      '0', 'a', '1', 'Undefined', 'C');

    await _insertQuestion(db, 13,
      'Euclid\'s Division Lemma: a =',
      'ಯೂಕ್ಲಿಡ್ ಭಾಗಾಕಾರ ಲೆಮ್ಮಾ: a =',
      'bq+r, 0≤r<b', 'bq-r, r>0', 'bq+r, r>b', 'bq×r', 'A');

    await _insertQuestion(db, 13,
      'HCF × LCM equals:',
      'ಮ.ಸಾ.ಅ × ಲ.ಸಾ.ಅ =',
      'Sum', 'Difference', 'Product', 'Square', 'C');

    await _insertQuestion(db, 9,
      'Which has definite volume but no shape?',
      'ನಿಶ್ಚಿತ ಗಾತ್ರ ಆದರೆ ಆಕಾರವಿಲ್ಲದ್ದು?',
      'Solid', 'Liquid', 'Gas', 'Plasma', 'B');

    await _insertQuestion(db, 9,
      'Boiling point of water is:',
      'ನೀರಿನ ಕುದಿಯುವ ಬಿಂದು:',
      '0°C', '50°C', '100°C', '200°C', 'C');

    await _insertQuestion(db, 15,
      'In combination reaction:',
      'ಸಂಯೋಜನ ಕ್ರಿಯೆಯಲ್ಲಿ:',
      'Substance breaks down', 'Two substances combine',
      'One element displaces', 'Two compounds exchange', 'B');

    await _insertQuestion(db, 15,
      'Oxidation involves:',
      'ಆಕ್ಸಿಡೀಕರಣದಲ್ಲಿ:',
      'Gain of electrons', 'Loss of electrons',
      'Gain of protons', 'Loss of neutrons', 'B');
  }

  Future<void> _insertLesson(Database db, String subject, int chapter,
      String title, int classLevel,
      String contentEnglish, String contentKannada) async {
    await db.insert('lessons', {
      'subject': subject,
      'chapter_number': chapter,
      'title': title,
      'content_english': contentEnglish,
      'content_kannada': contentKannada,
      'class_level': classLevel,
      'is_completed': 0,
    });
  }

  Future<void> _insertQuestion(Database db, int lessonId,
      String questionEn, String questionKn,
      String a, String b, String c, String d, String correct) async {
    await db.insert('questions', {
      'lesson_id': lessonId,
      'question_english': questionEn,
      'question_kannada': questionKn,
      'option_a': a,
      'option_b': b,
      'option_c': c,
      'option_d': d,
      'correct_option': correct,
    });
  }
}