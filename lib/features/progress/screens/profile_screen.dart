import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_repository.dart';
import '../../lessons/screens/login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _studentName = '';
  String _studentId = '';
  String _studentClass = '';
  String _studentMedium = '';
  int _completedLessons = 0;
  int _totalQuizzes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox('settings');
    final name =
        box.get('student_name', defaultValue: '');
    final id =
        box.get('student_id', defaultValue: 'STU000');
    final cls =
        box.get('student_class', defaultValue: '9');
    final medium =
        box.get('medium', defaultValue: 'english');

    final repo = DatabaseRepository();
    final subjects = [
      'Mathematics', 'Science', 'Social Studies',
      'English', 'Kannada', 'Hindi'
    ];
    int completed = 0;
    for (final s in subjects) {
      completed += await repo.getCompletedCount(s);
    }
    final progress = await repo.getAllProgress();

    setState(() {
      _studentName = name;
      _studentId = id;
      _studentClass = cls;
      _studentMedium = medium;
      _completedLessons = completed;
      _totalQuizzes = progress.length;
      _isLoading = false;
    });
  }

  String get _initials {
    final parts = _studentName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _studentName.isNotEmpty
        ? _studentName[0].toUpperCase()
        : 'S';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile / ಪ್ರೊಫೈಲ್'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
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
                  Text(
                    _studentName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎓 Class $_studentClass',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B1FA2)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '📖 ${_studentMedium == 'kannada' ? 'ಕನ್ನಡ ಮಾಧ್ಯಮ' : 'English Medium'}',
                          style: const TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                      children: [
                        _InfoRow(
                          icon: Icons.badge,
                          label: 'Student ID',
                          value: _studentId,
                        ),
                        Divider(
                            height: 24,
                            color: Theme.of(context)
                                .dividerColor),
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Name / ಹೆಸರು',
                          value: _studentName,
                        ),
                        Divider(
                            height: 24,
                            color: Theme.of(context)
                                .dividerColor),
                        _InfoRow(
                          icon: Icons.school,
                          label: 'Class / ತರಗತಿ',
                          value:
                              'Class $_studentClass — KSEEB',
                        ),
                        Divider(
                            height: 24,
                            color: Theme.of(context)
                                .dividerColor),
                        _InfoRow(
                          icon: Icons.language,
                          label: 'Medium / ಮಾಧ್ಯಮ',
                          value: _studentMedium ==
                                  'kannada'
                              ? 'Kannada Medium'
                              : 'English Medium',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress stats
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                        Text(
                          'My Progress / ನನ್ನ ಪ್ರಗತಿ',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight:
                                      FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                icon: '📚',
                                value:
                                    '$_completedLessons',
                                label: 'Textbooks',
                                color: const Color(
                                    0xFFE8F5E9),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                icon: '📝',
                                value: '$_totalQuizzes',
                                label: 'Quizzes',
                                color: const Color(
                                    0xFFE3F2FD),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Settings button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SettingsScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadProfile();
                        }
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text(
                          'Settings / ಸೆಟ್ಟಿಂಗ್ಸ್'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final box = await Hive.openBox('settings');

                        // Save everything that must persist across logouts
                        final studentHistory = box.get('student_history', defaultValue: <dynamic, dynamic>{});
                        final teacherName = box.get('teacher_name', defaultValue: '');
                        final teacherSchool = box.get('teacher_school', defaultValue: '');
                        final teacherSubject = box.get('teacher_subject', defaultValue: '');
                        final teacherPassword = box.get('teacher_password', defaultValue: '');
                        final teacherId = box.get('teacher_id', defaultValue: '');
                        final darkMode = box.get('dark_mode', defaultValue: false);
                        final onboardingDone = box.get('onboarding_done', defaultValue: false);

                        await box.clear();

                        // Restore everything
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
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout,
                          color: Colors.red),
                      label: const Text(
                        'Logout / ಲಾಗ್ ಔಟ್',
                        style:
                            TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
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
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
              color: AppTheme.textMuted, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
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
        color: color.withValues(
          alpha:
              Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon,
              style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}