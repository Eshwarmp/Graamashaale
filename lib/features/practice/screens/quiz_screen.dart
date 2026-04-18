import 'package:flutter/material.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/lesson_model.dart';
import '../../../core/database/question_model.dart';
import '../../../core/database/progress_model.dart';
import '../../../core/theme/app_theme.dart';
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
  bool _isLoading = true;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _answered = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _repo.getQuestionsByLesson(widget.lesson.id!);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
      if (option == _questions[_currentIndex].correctOption) {
        _score++;
      }
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      // Save progress
      await _repo.saveProgress(Progress(
        lessonId: widget.lesson.id!,
        score: _score,
        total: _questions.length,
        attemptedAt: DateTime.now().toIso8601String(),
      ));

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
  }

  Color _getOptionColor(String option) {
    if (!_answered) return AppTheme.surface;
    final correct = _questions[_currentIndex].correctOption;
    if (option == correct) return const Color(0xFFE8F5E9);
    if (option == _selectedOption) return const Color(0xFFFFEBEE);
    return AppTheme.surface;
  }

  Color _getOptionBorderColor(String option) {
    if (!_answered) return Colors.transparent;
    final correct = _questions[_currentIndex].correctOption;
    if (option == correct) return AppTheme.primary;
    if (option == _selectedOption) return Colors.red;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: const Center(
          child: Text('No questions available for this lesson yet!'),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Quiz — ${widget.lesson.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                Text(
                  'Score: $_score',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                question.question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...options.entries.map((entry) {
              return GestureDetector(
                onTap: () => _selectOption(entry.key),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getOptionColor(entry.key),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getOptionBorderColor(entry.key),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textDark,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),

            // Next button
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Next Question'
                        : 'See Results',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}