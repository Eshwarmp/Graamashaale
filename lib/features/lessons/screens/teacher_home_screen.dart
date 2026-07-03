import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/progress_model.dart';
import '../../../core/database/doubt_model.dart';
import 'login_screen.dart';
import 'teacher_profile_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() =>
      _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  int _totalDoubts = 0;
  int _pendingDoubts = 0;
  int _completedLessons = 0;
  int _totalQuizzes = 0;
  List<Doubt> _doubts = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  String _teacherName = '';
  String _teacherSchool = '';
  String _teacherSubject = '';

  DateTime? _lastBackPressTime;

  final Map<String, Map<String, dynamic>> _subjectInfo = {
    'Mathematics': {'icon': '📐', 'color': const Color(0xFFE3F2FD)},
    'Science': {'icon': '🔬', 'color': const Color(0xFFE8F5E9)},
    'Social Studies': {'icon': '🌍', 'color': const Color(0xFFFFF8E1)},
    'English': {'icon': '📖', 'color': const Color(0xFFFCE4EC)},
    'Kannada': {'icon': '🔤', 'color': const Color(0xFFEDE7F6)},
    'Hindi': {'icon': '📝', 'color': const Color(0xFFFFF3E0)},
    'All Subjects': {'icon': '📚', 'color': const Color(0xFFE8F5E9)},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<String> get _displaySubjects {
    if (_teacherSubject == 'All Subjects') {
      return [
        'Mathematics', 'Science', 'Social Studies',
        'English', 'Kannada', 'Hindi'
      ];
    }
    return [_teacherSubject];
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox('settings');
    final teacherSubject =
        box.get('teacher_subject', defaultValue: 'All Subjects');
    final teacherName =
        box.get('teacher_name', defaultValue: 'Teacher');
    final teacherSchool =
        box.get('teacher_school', defaultValue: '');

    List<Doubt> allDoubts;
    if (teacherSubject == 'All Subjects') {
      allDoubts = await _repo.getAllDoubts();
    } else {
      allDoubts = await _repo.getDoubtsBySubject(teacherSubject);
    }

    final unsyncedDoubts =
        allDoubts.where((d) => !d.isSynced).toList();

    final allProgress = await _repo.getAllProgressAllStudents();

    int completed = 0;
    final subjects = teacherSubject == 'All Subjects'
        ? ['Mathematics', 'Science', 'Social Studies', 'English', 'Kannada', 'Hindi']
        : [teacherSubject];

    for (final subject in subjects) {
      completed += await _repo.getCompletedCountAllStudents(subject);
    }

    int quizCount = 0;
    if (teacherSubject == 'All Subjects') {
      quizCount = allProgress.length;
    } else {
      for (final p in allProgress) {
        final lesson = await _repo.getLessonById(p.lessonId);
        if (lesson != null && lesson.subject == teacherSubject) {
          quizCount++;
        }
      }
    }

    setState(() {
      _teacherName = teacherName;
      _teacherSchool = teacherSchool;
      _teacherSubject = teacherSubject;
      _totalDoubts = allDoubts.length;
      _pendingDoubts = unsyncedDoubts.length;
      _doubts = allDoubts;
      _completedLessons = completed;
      _totalQuizzes = quizCount;
      _isLoading = false;
    });
  }

  Future<void> _handleBackPress() async {
    final now = DateTime.now();
    final isWarningActive = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2);

    if (isWarningActive) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressTime = now;
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherProfileScreen(),
                  ),
                );
                if (result == true) _loadData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_alert, color: Colors.white),
              tooltip: 'Post Announcement',
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => PostAnnouncementDialog(
                    teacherName: _teacherName,
                    teacherSubject: _teacherSubject,
                  ),
                );
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Announcement posted! 📢'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                final box = await Hive.openBox('settings');

                final studentHistory = box.get('student_history',
                    defaultValue: <dynamic, dynamic>{});
                final teacherName =
                    box.get('teacher_name', defaultValue: '');
                final teacherSchool =
                    box.get('teacher_school', defaultValue: '');
                final teacherSubject =
                    box.get('teacher_subject', defaultValue: '');
                final teacherPassword =
                    box.get('teacher_password', defaultValue: 'teacher123');
                final teacherId =
                    box.get('teacher_id', defaultValue: '');
                final darkMode =
                    box.get('dark_mode', defaultValue: false);
                final onboardingDone =
                    box.get('onboarding_done', defaultValue: false);

                await box.clear();

                await box.put('student_history', studentHistory);
                await box.put('onboarding_done', onboardingDone);
                await box.put('dark_mode', darkMode);

                if (teacherName.isNotEmpty) {
                  await box.put('teacher_name', teacherName);
                  await box.put('teacher_school', teacherSchool);
                  await box.put('teacher_subject', teacherSubject);
                  await box.put('teacher_password', teacherPassword);
                  await box.put('teacher_id', teacherId);
                }

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Teacher info bar
                  Container(
                    width: double.infinity,
                    color: AppTheme.primary.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _teacherName.isNotEmpty
                                  ? _teacherName[0].toUpperCase()
                                  : 'T',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
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
                                _teacherName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$_teacherSchool • $_teacherSubject',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab bar
                  Container(
                    color: AppTheme.primary,
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Overview',
                          icon: Icons.dashboard,
                          isSelected: _selectedTab == 0,
                          onTap: () =>
                              setState(() => _selectedTab = 0),
                        ),
                        _TabButton(
                          label: 'Doubts',
                          icon: Icons.question_answer,
                          isSelected: _selectedTab == 1,
                          onTap: () =>
                              setState(() => _selectedTab = 1),
                          badge: _pendingDoubts,
                        ),
                        _TabButton(
                          label: 'Students',
                          icon: Icons.people,
                          isSelected: _selectedTab == 2,
                          onTap: () =>
                              setState(() => _selectedTab = 2),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _selectedTab == 0
                        ? _buildOverview()
                        : _selectedTab == 1
                            ? _buildDoubts()
                            : _buildStudents(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOverview() {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
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
                  Text(
                    'ನಮಸ್ಕಾರ, $_teacherName! 👩‍🏫',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _teacherSchool,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'GraamaShaale — $_teacherSubject',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              _teacherSubject == 'All Subjects'
                  ? 'Overall Student Activity'
                  : '$_teacherSubject — Student Activity',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: [
                _StatCard(
                  icon: '📚',
                  value: '$_completedLessons',
                  label: 'Textbooks\nCompleted',
                  color: const Color(0xFFE8F5E9),
                ),
                _StatCard(
                  icon: '📝',
                  value: '$_totalQuizzes',
                  label: 'Quizzes\nAttempted',
                  color: const Color(0xFFE3F2FD),
                ),
                _StatCard(
                  icon: '❓',
                  value: '$_totalDoubts',
                  label: 'Total\nDoubts',
                  color: const Color(0xFFFFF8E1),
                ),
                _StatCard(
                  icon: '🔔',
                  value: '$_pendingDoubts',
                  label: 'Pending\nDoubts',
                  color: const Color(0xFFFFEBEE),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Subject Progress',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'ವಿಷಯವಾರು ಪ್ರಗತಿ  •  Tap to see details',
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),

            ..._displaySubjects.map((subject) {
              final info = _subjectInfo[subject] ??
                  {'icon': '📚', 'color': const Color(0xFFE8F5E9)};
              return _SubjectProgressRow(
                subject: subject,
                icon: info['icon'] as String,
                color: info['color'] as Color,
                repo: _repo,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubts() {
    if (_doubts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❓', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'No doubts yet!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _teacherSubject == 'All Subjects'
                  ? 'Student doubts will appear here.'
                  : 'No doubts for $_teacherSubject yet.',
              style: TextStyle(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _doubts.length,
        itemBuilder: (context, index) {
          return _DoubtCard(
            doubt: _doubts[index],
            repo: _repo,
            onAnswered: _loadData,
          );
        },
      ),
    );
  }

  Widget _buildStudents() {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadData,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .orderBy('registered_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👨‍🎓',
                      style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(
                    'No students registered yet!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Students will appear here after registration.',
                    style: TextStyle(color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final students = snapshot.data!.docs;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                color: Theme.of(context).cardColor,
                child: Row(
                  children: [
                    Text(
                      '${students.length} Students Registered',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${students.length} total',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final data = students[index].data()
                        as Map<String, dynamic>;
                    return _StudentCard(data: data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Tab Button ──────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badge;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ───────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark
              ? 0.2
              : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.15,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subject Progress Row (tappable → opens detail screen) ──
class _SubjectProgressRow extends StatefulWidget {
  final String subject;
  final String icon;
  final Color color;
  final DatabaseRepository repo;

  const _SubjectProgressRow({
    required this.subject,
    required this.icon,
    required this.color,
    required this.repo,
  });

  @override
  State<_SubjectProgressRow> createState() =>
      _SubjectProgressRowState();
}

class _SubjectProgressRowState
    extends State<_SubjectProgressRow> {
  int _completed = 0;
  int _quizzes = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final completed =
        await widget.repo.getCompletedCountAllStudents(widget.subject);

    final allProgress = await widget.repo.getAllProgressAllStudents();
    int quizCount = 0;
    for (final p in allProgress) {
      final lesson = await widget.repo.getLessonById(p.lessonId);
      if (lesson != null && lesson.subject == widget.subject) {
        quizCount++;
      }
    }

    if (mounted) {
      setState(() {
        _completed = completed;
        _quizzes = quizCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailScreen(
              subject: widget.subject,
              icon: widget.icon,
              color: widget.color,
              repo: widget.repo,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
                color: widget.color.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.3
                      : 1.0,
                ),
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
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 13, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$_completed textbooks completed',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.quiz,
                          size: 13, color: const Color(0xFF1565C0)),
                      const SizedBox(width: 4),
                      Text(
                        '$_quizzes quizzes attempted',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Subject Detail Screen ───────────────────────────────
class SubjectDetailScreen extends StatefulWidget {
  final String subject;
  final String icon;
  final Color color;
  final DatabaseRepository repo;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
    required this.icon,
    required this.color,
    required this.repo,
  });

  @override
  State<SubjectDetailScreen> createState() =>
      _SubjectDetailScreenState();
}

class _SubjectDetailScreenState
    extends State<SubjectDetailScreen> {
  bool _isLoading = true;

  // List of {studentId, studentName, lessonTitle, score, total, percentage, attemptedAt}
  List<Map<String, dynamic>> _quizResults = [];
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    // 1. completed textbooks for this subject (all students)
    final completed =
        await widget.repo.getCompletedCountAllStudents(widget.subject);

    // 2. all progress across all students
    final allProgress = await widget.repo.getAllProgressAllStudents();

    // 3. get student history from Hive to map student_id → name
    final box = await Hive.openBox('settings');
    final rawHistory =
        box.get('student_history', defaultValue: <dynamic, dynamic>{});
    final historyMap = Map<String, String>.from(
        rawHistory.map((k, v) => MapEntry(k.toString(), v.toString())));

    // Invert: student_id → display name (name_class)
    final Map<String, String> idToName = {};
    historyMap.forEach((key, studentId) {
      // key is "name_class", e.g. "eshwar_9"
      final parts = key.split('_');
      if (parts.length >= 2) {
        final name = parts
            .sublist(0, parts.length - 1)
            .join(' ');
        final cls = parts.last;
        idToName[studentId] =
            '${name[0].toUpperCase()}${name.substring(1)} (Class $cls)';
      }
    });

    // 4. filter progress by this subject
    final List<Map<String, dynamic>> results = [];
    for (final p in allProgress) {
      final lesson = await widget.repo.getLessonById(p.lessonId);
      if (lesson == null || lesson.subject != widget.subject) continue;

      final pct = p.total == 0 ? 0.0 : (p.score / p.total) * 100;
      results.add({
        'progressId': p.id ?? 0,
        'studentId': p.studentId,
        'studentName': idToName[p.studentId] ?? 'Student (${p.studentId.substring(0, 6)})',
        'lessonTitle': lesson.title,
        'score': p.score,
        'total': p.total,
        'percentage': pct,
        'attemptedAt': p.attemptedAt,
      });
    }

    // Sort: latest first
    results.sort((a, b) =>
        (b['attemptedAt'] as String).compareTo(a['attemptedAt'] as String));

    if (mounted) {
      setState(() {
        _completedCount = completed;
        _quizResults = results;
        _isLoading = false;
      });
    }
  }

  Color _scoreColor(double pct) {
    if (pct >= 80) return const Color(0xFF2E7D32);
    if (pct >= 60) return const Color(0xFF1565C0);
    if (pct >= 40) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }

  String _scoreLabel(double pct) {
    if (pct >= 80) return 'Excellent 🎉';
    if (pct >= 60) return 'Good 👍';
    if (pct >= 40) return 'Average 💪';
    return 'Needs Work 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.icon} ${widget.subject}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          icon: '📚',
                          value: '$_completedCount',
                          label: 'Textbooks\nCompleted',
                          color: const Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          icon: '📝',
                          value: '${_quizResults.length}',
                          label: 'Quizzes\nAttempted',
                          color: const Color(0xFFE3F2FD),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          icon: '⭐',
                          value: _quizResults.isEmpty
                              ? '0%'
                              : '${(_quizResults.map((r) => r['percentage'] as double).reduce((a, b) => a + b) / _quizResults.length).toStringAsFixed(0)}%',
                          label: 'Avg\nScore',
                          color: const Color(0xFFFFF8E1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quiz results header
                  Text(
                    'Student Quiz Results',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ವಿದ್ಯಾರ್ಥಿಗಳ ರಸಪ್ರಶ್ನೆ ಫಲಿತಾಂಶ',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  if (_quizResults.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('📝',
                                style: TextStyle(fontSize: 50)),
                            const SizedBox(height: 12),
                            Text(
                              'No quizzes attempted yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quiz results will appear here once students attempt quizzes for ${widget.subject}.',
                              style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...(_quizResults.map((result) {
                      final pct =
                          result['percentage'] as double;
                      final score = result['score'] as int;
                      final total = result['total'] as int;
                      final date =
                          (result['attemptedAt'] as String)
                              .substring(0, 10);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizAnswerDetailScreen(
                                progressId: result['progressId'] as int,
                                studentName: result['studentName'] as String,
                                lessonTitle: result['lessonTitle'] as String,
                                score: score,
                                total: total,
                                repo: widget.repo,
                              ),
                            ),
                          );
                        },
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _scoreColor(pct)
                                .withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Student name + date
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      (result['studentName']
                                              as String)[0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result['studentName']
                                            as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        result['lessonTitle']
                                            as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Score bar
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Score: $score / $total',
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            '${pct.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize: 14,
                                              color: _scoreColor(pct),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child:
                                            LinearProgressIndicator(
                                          value: total == 0
                                              ? 0
                                              : score / total,
                                          minHeight: 8,
                                          backgroundColor: Colors
                                              .grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<
                                                  Color>(
                                            _scoreColor(pct),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Correct / Wrong breakdown
                            Row(
                              children: [
                                // Correct
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: Color(0xFF2E7D32)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$score Correct',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Wrong
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cancel,
                                          size: 14,
                                          color: Color(0xFFC62828)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${total - score} Wrong',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFC62828),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Label
                                Flexible(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _scoreColor(pct)
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _scoreLabel(pct),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _scoreColor(pct),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.touch_app,
                                    size: 12, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to see question details',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      );
                    })),
                ],
              ),
            ),
    );
  }
}

// ── Quiz Answer Detail Screen ───────────────────────────
class QuizAnswerDetailScreen extends StatefulWidget {
  final int progressId;
  final String studentName;
  final String lessonTitle;
  final int score;
  final int total;
  final DatabaseRepository repo;

  const QuizAnswerDetailScreen({
    super.key,
    required this.progressId,
    required this.studentName,
    required this.lessonTitle,
    required this.score,
    required this.total,
    required this.repo,
  });

  @override
  State<QuizAnswerDetailScreen> createState() =>
      _QuizAnswerDetailScreenState();
}

class _QuizAnswerDetailScreenState
    extends State<QuizAnswerDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final answers =
        await widget.repo.getProgressAnswers(widget.progressId);
    setState(() {
      _answers = answers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.total == 0
        ? 0.0
        : (widget.score / widget.total) * 100;

    Color scoreColor;
    if (pct >= 80) scoreColor = const Color(0xFF2E7D32);
    else if (pct >= 60) scoreColor = const Color(0xFF1565C0);
    else if (pct >= 40) scoreColor = const Color(0xFFF57F17);
    else scoreColor = const Color(0xFFC62828);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lessonTitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${pct.toStringAsFixed(0)}%',
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
                                    '${widget.score} correct out of ${widget.total}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Text('✅ ',
                                          style: TextStyle(
                                              fontSize: 12)),
                                      Text(
                                        '${widget.score} Right',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('❌ ',
                                          style: TextStyle(
                                              fontSize: 12)),
                                      Text(
                                        '${widget.total - widget.score} Wrong',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Question-wise Breakdown',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ಪ್ರಶ್ನೆವಾರು ವಿವರ',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  if (_answers.isEmpty)
                    // No detailed answers saved (old quiz attempt)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('📋',
                                style: TextStyle(fontSize: 50)),
                            const SizedBox(height: 12),
                            Text(
                              'Detailed breakdown not available',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This quiz was attempted before per-question tracking was enabled. Future quizzes will show full question details.',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(_answers.length, (index) {
                      final a = _answers[index];
                      final isCorrect = (a['is_correct'] as int) == 1;
                      final selected = a['selected_option'] as String;
                      final correct = a['correct_option'] as String;

                      final optionLabels = {
                        'A': a['option_a'] as String,
                        'B': a['option_b'] as String,
                        'C': a['option_c'] as String,
                        'D': a['option_d'] as String,
                      };

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCorrect
                                ? const Color(0xFF2E7D32)
                                    .withValues(alpha: 0.4)
                                : const Color(0xFFC62828)
                                    .withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Question header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? const Color(0xFF2E7D32)
                                        .withValues(alpha: 0.08)
                                    : const Color(0xFFC62828)
                                        .withValues(alpha: 0.08),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      a['question_english'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isCorrect
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),

                            // Kannada question
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 8, 16, 4),
                              child: Text(
                                a['question_kannada'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),

                            const Divider(height: 1),

                            // Options
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: optionLabels.entries
                                    .map((entry) {
                                  final letter = entry.key;
                                  final text = entry.value;
                                  final isSelected =
                                      selected == letter;
                                  final isCorrectOption =
                                      correct == letter;

                                  Color bgColor;
                                  Color textColor;
                                  IconData? trailingIcon;

                                  if (isCorrectOption) {
                                    bgColor = const Color(0xFFE8F5E9);
                                    textColor =
                                        const Color(0xFF2E7D32);
                                    trailingIcon =
                                        Icons.check_circle;
                                  } else if (isSelected &&
                                      !isCorrectOption) {
                                    bgColor = const Color(0xFFFFEBEE);
                                    textColor =
                                        const Color(0xFFC62828);
                                    trailingIcon = Icons.cancel;
                                  } else {
                                    bgColor = Colors.transparent;
                                    textColor = Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.black;
                                    trailingIcon = null;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 6),
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCorrectOption
                                            ? const Color(0xFF2E7D32)
                                                .withValues(alpha: 0.5)
                                            : isSelected
                                                ? const Color(
                                                        0xFFC62828)
                                                    .withValues(
                                                        alpha: 0.5)
                                                : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isCorrectOption
                                                ? const Color(
                                                    0xFF2E7D32)
                                                : isSelected
                                                    ? const Color(
                                                        0xFFC62828)
                                                    : Colors.grey[400],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              letter,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: textColor,
                                              fontWeight: isCorrectOption ||
                                                      isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        if (trailingIcon != null)
                                          Icon(
                                            trailingIcon,
                                            size: 18,
                                            color: isCorrectOption
                                                ? const Color(
                                                    0xFF2E7D32)
                                                : const Color(
                                                    0xFFC62828),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // Wrong answer explanation
                            if (!isCorrect)
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                    12, 0, 12, 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFF9A825)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('💡',
                                        style:
                                            TextStyle(fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Correct answer: ${optionLabels[correct]} ($correct)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF7B5800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

// ── Mini Stat Card (used in detail screen) ──────────────
class _MiniStatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark
              ? 0.2
              : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student Card ────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _StudentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Unknown';
    final cls = data['class'] ?? '-';
    final medium = data['medium'] ?? 'english';
    final studentId = data['student_id'] ?? '';
    final registeredAt = data['registered_at'] ?? '';

    final initials = name.isNotEmpty
        ? name.trim().split(' ').length >= 2
            ? '${name.trim().split(' ')[0][0]}${name.trim().split(' ')[1][0]}'
                .toUpperCase()
            : name[0].toUpperCase()
        : 'S';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              color: AppTheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
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
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Class $cls',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B1FA2)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        medium == 'kannada' ? 'ಕನ್ನಡ' : 'English',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7B1FA2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  studentId,
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                registeredAt.length >= 10
                    ? registeredAt.substring(0, 10)
                    : '',
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Doubt Card ──────────────────────────────────────────
class _DoubtCard extends StatefulWidget {
  final Doubt doubt;
  final DatabaseRepository repo;
  final VoidCallback onAnswered;

  const _DoubtCard({
    required this.doubt,
    required this.repo,
    required this.onAnswered,
  });

  @override
  State<_DoubtCard> createState() => _DoubtCardState();
}

class _DoubtCardState extends State<_DoubtCard> {
  final _answerController = TextEditingController();
  bool _isReplying = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.doubt.isSynced
              ? Colors.transparent
              : AppTheme.secondary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF1565C0).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.doubt.subject,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.doubt.isSynced
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.doubt.isSynced ? '✅ Answered' : '🔔 Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.doubt.isSynced
                        ? AppTheme.primary
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.person,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                widget.doubt.studentName ?? 'Unknown Student',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text('•',
                  style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              Text(
                'Class ${widget.doubt.studentClass ?? '-'}',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
              const Spacer(),
              Text(
                widget.doubt.createdAt.substring(0, 10),
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            '❓ ${widget.doubt.question}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),

          if (widget.doubt.isSynced &&
              widget.doubt.answer != null &&
              widget.doubt.answer!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👩‍🏫 Your Answer:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.doubt.answer!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],

          if (!widget.doubt.isSynced) ...[
            const SizedBox(height: 12),
            if (!_isReplying)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      setState(() => _isReplying = true),
                  icon: const Icon(Icons.reply),
                  label: const Text('Reply / ಉತ್ತರಿಸಿ'),
                ),
              )
            else ...[
              TextField(
                controller: _answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Type your answer...\nನಿಮ್ಮ ಉತ್ತರ ಬರೆಯಿರಿ...',
                  hintStyle:
                      TextStyle(color: AppTheme.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _isReplying = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_answerController.text
                                  .trim()
                                  .isEmpty) return;
                              setState(
                                  () => _isSubmitting = true);
                              await widget.repo.answerDoubt(
                                widget.doubt.id!,
                                _answerController.text.trim(),
                              );
                              widget.onAnswered();
                              setState(() {
                                _isSubmitting = false;
                                _isReplying = false;
                              });
                            },
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Send Answer'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Post Announcement Dialog ────────────────────────────
class PostAnnouncementDialog extends StatefulWidget {
  final String teacherName;
  final String teacherSubject;

  const PostAnnouncementDialog({
    super.key,
    required this.teacherName,
    required this.teacherSubject,
  });

  @override
  State<PostAnnouncementDialog> createState() =>
      _PostAnnouncementDialogState();
}

class _PostAnnouncementDialogState
    extends State<PostAnnouncementDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isPosting = false;

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      _messageController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📢',
                      style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'New Announcement',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Title / ಶೀರ್ಷಿಕೆ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Message / ಸಂದೇಶ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isValid && !_isPosting
                          ? () async {
                              setState(() => _isPosting = true);
                              try {
                                await FirebaseFirestore.instance
                                    .collection('announcements')
                                    .add({
                                  'title':
                                      _titleController.text.trim(),
                                  'message':
                                      _messageController.text.trim(),
                                  'teacher_name': widget.teacherName,
                                  'subject': widget.teacherSubject,
                                  'created_at':
                                      DateTime.now().toIso8601String(),
                                });
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              } catch (e) {
                                setState(() => _isPosting = false);
                              }
                            }
                          : null,
                      icon: _isPosting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}