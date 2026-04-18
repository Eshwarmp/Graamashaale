import 'package:flutter/material.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/lesson_model.dart';
import '../../../core/theme/app_theme.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String subject;
  final Color color;

  const LessonsScreen({
    super.key,
    required this.subject,
    required this.color,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  List<Lesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await _repo.getLessonsBySubject(widget.subject);
    setState(() {
      _lessons = lessons;
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
                      const Text('📚', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        'No lessons yet!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _lessons[index];
                    return _LessonCard(
                      lesson: lesson,
                      color: widget.color,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonDetailScreen(
                              lesson: lesson,
                            ),
                          ),
                        );
                        _loadLessons();
                      },
                    );
                  },
                ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Color color;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.color,
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
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
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${lesson.chapterNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${lesson.chapterNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              lesson.isCompleted
                  ? Icons.check_circle
                  : Icons.arrow_forward_ios,
              color: lesson.isCompleted ? AppTheme.primary : AppTheme.textMuted,
              size: lesson.isCompleted ? 24 : 16,
            ),
          ],
        ),
      ),
    );
  }
}