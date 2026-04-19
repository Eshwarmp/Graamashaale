import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/lesson_model.dart';
import '../../../core/theme/app_theme.dart';
import 'pdf_viewer_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String subject;
  final Color color;
  final String icon;

  const LessonsScreen({
    super.key,
    required this.subject,
    required this.color,
    required this.icon,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  int _classLevel = 9;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final box = await Hive.openBox('settings');
    final classStr = box.get('student_class', defaultValue: '9');
    final classLevel = int.tryParse(classStr.toString()) ?? 9;
    final lessons =
        await _repo.getLessonsBySubject(widget.subject, classLevel);
    setState(() {
      _lessons = lessons;
      _classLevel = classLevel;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.subject),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.icon,
                          style: const TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        'No content available!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Class $_classLevel — ${widget.subject}',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class badge
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Class $_classLevel • KSEEB',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_lessons.length} textbooks',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = _lessons[index];
                          return _LessonCard(
                            lesson: lesson,
                            color: widget.color,
                            icon: widget.icon,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(
                                    lesson: lesson,
                                  ),
                                ),
                              );
                              _loadLessons();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Color color;
  final String icon;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Part ${lesson.part}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 14,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'KSEEB Textbook',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status icon
            Icon(
              lesson.isCompleted
                  ? Icons.check_circle
                  : Icons.arrow_forward_ios,
              color: lesson.isCompleted
                  ? AppTheme.primary
                  : AppTheme.textMuted,
              size: lesson.isCompleted ? 24 : 16,
            ),
          ],
        ),
      ),
    );
  }
}