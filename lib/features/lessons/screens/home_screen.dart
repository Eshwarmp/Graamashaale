import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/progress/screens/profile_screen.dart';
// import '../../../features/progress/screens/progress_screen.dart';
// import '../../../features/doubt/screens/doubt_screen.dart';
import 'lessons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _studentName = '';
  String _studentClass = '';

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _studentName = box.get('student_name', defaultValue: 'Student');
      _studentClass = box.get('student_class', defaultValue: '9');
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

  void _openSubject(BuildContext context, String subject,
      String icon, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonsScreen(
          subject: subject,
          color: color,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('ಗ್ರಾಮಶಾಲೆ'),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
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
                    'ನಮಸ್ಕಾರ, $_studentName! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class $_studentClass • KSEEB Karnataka',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ಕಲಿಕೆ, ಎಲ್ಲಿಂದಲೂ. ಯಾವಾಗಲೂ. 📚',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Core subjects
            Text(
              'Core Subjects',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'ಮುಖ್ಯ ವಿಷಯಗಳು',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _SubjectCard(
                  title: 'ಗಣಿತ',
                  subtitle: 'Mathematics',
                  icon: '📐',
                  color: const Color(0xFFE3F2FD),
                  onTap: () => _openSubject(context,
                      'Mathematics', '📐',
                      const Color(0xFFE3F2FD)),
                ),
                _SubjectCard(
                  title: 'ವಿಜ್ಞಾನ',
                  subtitle: 'Science',
                  icon: '🔬',
                  color: const Color(0xFFE8F5E9),
                  onTap: () => _openSubject(context,
                      'Science', '🔬',
                      const Color(0xFFE8F5E9)),
                ),
                _SubjectCard(
                  title: 'ಸಮಾಜ ವಿಜ್ಞಾನ',
                  subtitle: 'Social Studies',
                  icon: '🌍',
                  color: const Color(0xFFFFF8E1),
                  onTap: () => _openSubject(context,
                      'Social Studies', '🌍',
                      const Color(0xFFFFF8E1)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Language subjects
            Text(
              'Languages',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'ಭಾಷಾ ವಿಷಯಗಳು',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _SubjectCard(
                  title: 'ಕನ್ನಡ',
                  subtitle: 'Kannada',
                  icon: '🔤',
                  color: const Color(0xFFEDE7F6),
                  onTap: () => _openSubject(context,
                      'Kannada', '🔤',
                      const Color(0xFFEDE7F6)),
                ),
                _SubjectCard(
                  title: 'ಇಂಗ್ಲಿಷ್',
                  subtitle: 'English',
                  icon: '📖',
                  color: const Color(0xFFFCE4EC),
                  onTap: () => _openSubject(context,
                      'English', '📖',
                      const Color(0xFFFCE4EC)),
                ),
                _SubjectCard(
                  title: 'ಹಿಂದಿ',
                  subtitle: 'Hindi',
                  icon: '📝',
                  color: const Color(0xFFFFF3E0),
                  onTap: () => _openSubject(context,
                      'Hindi', '📝',
                      const Color(0xFFFFF3E0)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon,
                  style: const TextStyle(fontSize: 32)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                  ),
                  Text(
                    subtitle,
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
      ),
    );
  }
}