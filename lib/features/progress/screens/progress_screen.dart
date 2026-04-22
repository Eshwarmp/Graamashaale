import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/progress_model.dart';
import '../../../core/theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  bool _isLoading = true;
  int _classLevel = 9;
  int _totalLessons = 0;
  int _completedLessons = 0;
  List<Progress> _quizHistory = [];

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Mathematics', 'icon': '📐', 'color': const Color(0xFFE3F2FD)},
    {'name': 'Science', 'icon': '🔬', 'color': const Color(0xFFE8F5E9)},
    {'name': 'Social Studies', 'icon': '🌍', 'color': const Color(0xFFFFF8E1)},
    {'name': 'English', 'icon': '📖', 'color': const Color(0xFFFCE4EC)},
    {'name': 'Kannada', 'icon': '🔤', 'color': const Color(0xFFEDE7F6)},
    {'name': 'Hindi', 'icon': '📝', 'color': const Color(0xFFFFF3E0)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox('settings');
    final classStr = box.get('student_class', defaultValue: '9');
    final classLevel = int.tryParse(classStr.toString()) ?? 9;

    int total = 0;
    int completed = 0;
    for (final s in _subjects) {
      final t = await _repo.getTotalCount(s['name'], classLevel);
      final c = await _repo.getCompletedCount(s['name']);
      total += t;
      completed += c;
    }

    final quizHistory = await _repo.getAllProgress();

    setState(() {
      _classLevel = classLevel;
      _totalLessons = total;
      _completedLessons = completed;
      _quizHistory = quizHistory;
      _isLoading = false;
    });
  }

  double get _overallProgress =>
      _totalLessons == 0 ? 0 : _completedLessons / _totalLessons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Progress / ನನ್ನ ಪ್ರಗತಿ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall progress card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'ಒಟ್ಟಾರೆ ಪ್ರಗತಿ',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '${(_overallProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_completedLessons of $_totalLessons textbooks',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _overallProgress,
                                      backgroundColor: Colors.white24,
                                      color: Colors.white,
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Class $_classLevel • KSEEB Karnataka',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subject wise progress
                  Text(
                    'Subject-wise Progress',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                  ),
                  const Text(
                    'ವಿಷಯವಾರು ಪ್ರಗತಿ',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._subjects.map(
                    (s) => _SubjectProgress(
                      subject: s['name'],
                      icon: s['icon'],
                      color: s['color'],
                      classLevel: _classLevel,
                      repo: _repo,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quiz history
                  Text(
                    'Quiz History',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                  ),
                  const Text(
                    'ರಸಪ್ರಶ್ನೆ ಇತಿಹಾಸ',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _quizHistory.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text('📝',
                                  style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 12),
                              Text(
                                'No quizzes attempted yet!',
                                style: TextStyle(
                                    color: AppTheme.textMuted),
                              ),
                              Text(
                                'ಇನ್ನೂ ರಸಪ್ರಶ್ನೆ ಪ್ರಯತ್ನಿಸಿಲ್ಲ!',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _quizHistory
                              .take(10)
                              .map((p) =>
                                  _QuizHistoryCard(progress: p))
                              .toList(),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

// ── Subject Progress Card ───────────────────────────────
class _SubjectProgress extends StatefulWidget {
  final String subject;
  final String icon;
  final Color color;
  final int classLevel;
  final DatabaseRepository repo;

  const _SubjectProgress({
    required this.subject,
    required this.icon,
    required this.color,
    required this.classLevel,
    required this.repo,
  });

  @override
  State<_SubjectProgress> createState() => _SubjectProgressState();
}

class _SubjectProgressState extends State<_SubjectProgress> {
  int _completed = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final completed =
        await widget.repo.getCompletedCount(widget.subject);
    final total = await widget.repo
        .getTotalCount(widget.subject, widget.classLevel);
    setState(() {
      _completed = completed;
      _total = total;
    });
  }

  double get _progress =>
      _total == 0 ? 0 : _completed / _total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(widget.icon,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    color: AppTheme.primary,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completed/$_total textbooks completed',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(_progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _progress > 0
                  ? AppTheme.primary
                  : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz History Card ───────────────────────────────────
class _QuizHistoryCard extends StatelessWidget {
  final Progress progress;

  const _QuizHistoryCard({required this.progress});

  Color get _color {
    if (progress.percentage >= 80) return const Color(0xFF2E7D32);
    if (progress.percentage >= 60) return const Color(0xFF1565C0);
    if (progress.percentage >= 40) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _color, width: 2),
            ),
            child: Center(
              child: Text(
                '${progress.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz — Lesson ${progress.lessonId}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${progress.score}/${progress.total} • ${progress.resultLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            progress.attemptedAt.substring(0, 10),
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}