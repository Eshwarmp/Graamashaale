import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/lesson_model.dart';
import '../../../core/database/question_model.dart';
import '../../../core/database/progress_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/sync/ai_service.dart';
import '../../../core/sync/sync_service.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _showKannada = false;
  String _loadingMessage = 'Loading quiz...';

  // Tracks the selected answer for EVERY question index
  // key = question index, value = option letter ('A','B','C','D')
  final Map<int, String> _selectedAnswers = {};

  // Language subjects — no bilingual toggle
  bool get _isLanguageSubject =>
      ['Kannada', 'Hindi', 'English']
          .contains(widget.lesson.subject);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _isGenerating = false;
      _currentIndex = 0;
      _score = 0;
      _selectedOption = null;
      _answered = false;
      _selectedAnswers.clear();
      _loadingMessage = 'Loading quiz...';
    });

    final box = await Hive.openBox('settings');
    final medium =
        box.get('medium', defaultValue: 'english');

    final isOnline =
        await SyncService.instance.isConnected();

    if (isOnline) {
      // Always delete and regenerate fresh
      await _repo.deleteQuestions(widget.lesson.id!);

      setState(() {
        _isGenerating = true;
        _loadingMessage =
            'Generating fresh questions with AI... ✨';
      });

      final aiQuestions =
          await AiService.instance.generateQuestions(
        subject: widget.lesson.subject,
        classLevel: widget.lesson.classLevel,
        part: widget.lesson.part,
        medium: medium,
        count: 10,
      );

      if (aiQuestions != null &&
          aiQuestions.isNotEmpty) {
        await _repo.saveAiQuestions(
            widget.lesson.id!, aiQuestions);
      }

      setState(() => _isGenerating = false);
    }

    // Load from DB
    final questions = await _repo
        .getQuestionsByLesson(widget.lesson.id!);

    // Shuffle every time
    questions.shuffle();

    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _selectOption(String option) {
    if (_answered) return;
    final isCorrect =
        option == _questions[_currentIndex].correctOption;
    setState(() {
      _selectedOption = option;
      _answered = true;
      // Save this answer for the current question index
      _selectedAnswers[_currentIndex] = option;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < (_questions.length - 1)) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final box = await Hive.openBox('settings');
    final studentId =
        box.get('student_id', defaultValue: 'default');

    // Save progress and get the inserted row ID
    final progressId = await _repo.saveProgressWithId(
      Progress(
        lessonId: widget.lesson.id!,
        studentId: studentId,
        score: _score,
        total: _questions.length,
        attemptedAt: DateTime.now().toIso8601String(),
      ),
    );

    // Build per-question answer records
    final List<Map<String, dynamic>> answers = [];
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final selected = _selectedAnswers[i] ?? '';
      final isCorrect = selected == q.correctOption;
      answers.add({
        'question_id': q.id ?? 0,
        'question_english': q.questionEnglish,
        'question_kannada': q.questionKannada,
        'option_a': q.optionA,
        'option_b': q.optionB,
        'option_c': q.optionC,
        'option_d': q.optionD,
        'correct_option': q.correctOption,
        'selected_option': selected,
        'is_correct': isCorrect,
      });
    }

    // Save all answers linked to this progress attempt
    await _repo.saveProgressAnswers(progressId, answers);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreScreen(
            score: _score,
            total: _questions.length,
            lessonTitle: widget.lesson.title,
          ),
        ),
      );
    }
  }

  Color _getOptionColor(String option) {
    if (!_answered) return Theme.of(context).cardColor;
    final correct =
        _questions[_currentIndex].correctOption;
    if (option == correct) {
      return const Color(0xFF2E7D32)
          .withValues(alpha: 0.15);
    }
    if (option == _selectedOption &&
        option != correct) {
      return const Color(0xFFC62828)
          .withValues(alpha: 0.15);
    }
    return Theme.of(context).cardColor;
  }

  Color _getOptionBorderColor(String option) {
    if (!_answered) {
      return Theme.of(context).brightness ==
              Brightness.dark
          ? Colors.grey[600]!
          : Colors.grey[300]!;
    }
    final correct =
        _questions[_currentIndex].correctOption;
    if (option == correct) {
      return const Color(0xFF2E7D32);
    }
    if (option == _selectedOption &&
        option != correct) {
      return const Color(0xFFC62828);
    }
    return Theme.of(context).brightness ==
            Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    // Loading / Generating screen
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (_isGenerating) ...[
                  const Text('🤖',
                      style:
                          TextStyle(fontSize: 70)),
                  const SizedBox(height: 24),
                  Text(
                    'AI is generating questions...',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            fontWeight:
                                FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ಪ್ರಶ್ನೆಗಳನ್ನು ರಚಿಸಲಾಗುತ್ತಿದೆ...',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.lesson.subject} • Class ${widget.lesson.classLevel} • Part ${widget.lesson.part}',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This may take a few seconds...',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12),
                  ),
                ] else ...[
                  const CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _loadingMessage,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // No questions screen
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text('📶',
                    style:
                        TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  'No questions available!',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                          fontWeight:
                              FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'ಪ್ರಶ್ನೆಗಳು ಲಭ್ಯವಿಲ್ಲ!',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary
                        .withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💡',
                          style: TextStyle(
                              fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Connect to internet and tap Try Again to generate AI questions.',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _repo.deleteQuestions(
                          widget.lesson.id!);
                      _loadQuestions();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                        'Try Again / ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final options = {
      'A': question.optionA,
      'B': question.optionB,
      'C': question.optionC,
      'D': question.optionD,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Quiz — Part ${widget.lesson.part}'),
        actions: [
          // Only show language toggle for core subjects
          if (!_isLanguageSubject)
            GestureDetector(
              onTap: () => setState(
                  () => _showKannada = !_showKannada),
              child: Container(
                margin:
                    const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  _showKannada ? 'English' : 'ಕನ್ನಡ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} of ${_questions.length}',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Text('🤖',
                            style: TextStyle(
                                fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Score: $_score',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) /
                        _questions.length,
                    backgroundColor:
                        Theme.of(context).brightness ==
                                Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[200],
                    color: AppTheme.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Row(
                          children: [
                            const Text('🤖',
                                style: TextStyle(
                                    fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'AI Generated',
                              style: TextStyle(
                                color:
                                    AppTheme.primary,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(
                                  0xFF1565C0)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Text(
                          widget.lesson.subject,
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_isLanguageSubject) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(
                                    0xFF7B1FA2)
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Text(
                            widget.lesson.subject ==
                                    'Kannada'
                                ? 'ಕನ್ನಡ ಮಾಧ್ಯಮ'
                                : widget.lesson
                                            .subject ==
                                        'Hindi'
                                    ? 'हिंदी'
                                    : 'English Only',
                            style: const TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Primary question
                        Text(
                          _isLanguageSubject
                              ? question.questionKannada
                              : _showKannada
                                  ? question
                                      .questionKannada
                                  : question
                                      .questionEnglish,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                                height: 1.5,
                              ),
                        ),

                        // Secondary translation
                        // Only for core subjects
                        if (!_isLanguageSubject) ...[
                          const SizedBox(height: 8),
                          Text(
                            _showKannada
                                ? question
                                    .questionEnglish
                                : question
                                    .questionKannada,
                            style: TextStyle(
                              color:
                                  AppTheme.textMuted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...options.entries.map((entry) {
                    final optionKey = entry.key;
                    final optionValue = entry.value;
                    final isCorrect = _answered &&
                        optionKey ==
                            question.correctOption;
                    final isWrong = _answered &&
                        optionKey ==
                            _selectedOption &&
                        optionKey !=
                            question.correctOption;

                    return GestureDetector(
                      onTap: () =>
                          _selectOption(optionKey),
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 200),
                        margin: const EdgeInsets.only(
                            bottom: 12),
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getOptionColor(
                              optionKey),
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                          border: Border.all(
                            color:
                                _getOptionBorderColor(
                                    optionKey),
                            width:
                                isCorrect || isWrong
                                    ? 2
                                    : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration:
                                  BoxDecoration(
                                color: isCorrect
                                    ? const Color(
                                        0xFF2E7D32)
                                    : isWrong
                                        ? const Color(
                                            0xFFC62828)
                                        : AppTheme
                                            .primary
                                            .withValues(
                                                alpha:
                                                    0.1),
                                shape:
                                    BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  optionKey,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    color: isCorrect ||
                                            isWrong
                                        ? Colors.white
                                        : AppTheme
                                            .primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                optionValue,
                                style: Theme.of(
                                        context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                              ),
                            ),
                            if (isCorrect)
                              const Icon(
                                Icons.check_circle,
                                color:
                                    Color(0xFF2E7D32),
                              ),
                            if (isWrong)
                              const Icon(
                                Icons.cancel,
                                color:
                                    Color(0xFFC62828),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom next button
          if (_answered)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex <
                            (_questions.length - 1)
                        ? 'Next Question / ಮುಂದಿನ ಪ್ರಶ್ನೆ →'
                        : 'Finish Quiz / ರಸಪ್ರಶ್ನೆ ಮುಗಿಸಿ ✅',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}