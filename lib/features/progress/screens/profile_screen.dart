import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_repository.dart';
import '../../lessons/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  String _name = '';
  String _studentClass = '';
  String _role = '';
  String _studentId = '';
  String _medium = '';
  int _completedLessons = 0;
  int _quizzesAttempted = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox('settings');
    final name = box.get('student_name', defaultValue: 'Student');
    final studentClass = box.get('student_class', defaultValue: '-');
    final role = box.get('role', defaultValue: 'student');
    final medium = box.get('medium', defaultValue: 'english');
    String studentId = box.get('student_id', defaultValue: '');

    if (studentId.isEmpty) {
      studentId =
          'STU${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      await box.put('student_id', studentId);
    }

    final subjects = [
      'Mathematics',
      'Science',
      'Social Studies',
      'English',
      'Kannada',
      'Hindi'
    ];
    int completed = 0;
    for (final subject in subjects) {
      completed += await _repo.getCompletedCount(subject);
    }

    final allProgress = await _repo.getAllProgress();

    setState(() {
      _name = name;
      _studentClass = studentClass;
      _role = role;
      _medium = medium;
      _studentId = studentId;
      _completedLessons = completed;
      _quizzesAttempted = allProgress.length;
    });
  }

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name.isNotEmpty ? _name[0].toUpperCase() : 'S';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Profile / ಪ್ರೊಫೈಲ್')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              _name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 8),

            // Role + medium badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _role == 'teacher'
                        ? const Color(0xFFFFF8E1)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _role == 'teacher'
                        ? '👩‍🏫 Teacher'
                        : '🧑‍🎓 Class $_studentClass',
                    style: TextStyle(
                      color: _role == 'teacher'
                          ? const Color(0xFFF9A825)
                          : AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _medium == 'kannada'
                        ? '🔤 ಕನ್ನಡ ಮಾಧ್ಯಮ'
                        : '📖 English Medium',
                    style: const TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Info card
            Container(
              width: double.infinity,
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
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.badge,
                    label: 'Student ID',
                    value: _studentId,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.person,
                    label: 'Name / ಹೆಸರು',
                    value: _name,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.school,
                    label: 'Class / ತರಗತಿ',
                    value: 'Class $_studentClass — KSEEB',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.language,
                    label: 'Medium / ಮಾಧ್ಯಮ',
                    value: _medium == 'kannada'
                        ? 'ಕನ್ನಡ ಮಾಧ್ಯಮ'
                        : 'English Medium',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats card
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Progress / ನನ್ನ ಪ್ರಗತಿ',
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: '📚',
                          value: '$_completedLessons',
                          label: 'Textbooks\nCompleted',
                          color: const Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatBox(
                          icon: '📝',
                          value: '$_quizzesAttempted',
                          label: 'Quizzes\nAttempted',
                          color: const Color(0xFFE3F2FD),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final box = await Hive.openBox('settings');
                  await box.clear();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout / ಲಾಗ್ ಔಟ್',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}