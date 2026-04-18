import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'lessons_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/progress/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('GraamaShaale'),
        centerTitle: false,
        actions: [
          FutureBuilder(
            future: Hive.openBox('settings'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final box = snapshot.data as Box;
              final name = box.get('student_name', defaultValue: 'U');
              final initials = name.trim().isNotEmpty
                  ? name.trim()[0].toUpperCase()
                  : 'U';
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back! 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'What do you want to study today?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              'Subjects',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _SubjectCard(
                    title: 'Mathematics',
                    icon: '📐',
                    color: const Color(0xFFE3F2FD),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonsScreen(
                          subject: 'Mathematics',
                          color: Color(0xFFE3F2FD),
                        ),
                      ),
                    ),
                  ),
                  _SubjectCard(
                    title: 'Science',
                    icon: '🔬',
                    color: const Color(0xFFE8F5E9),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonsScreen(
                          subject: 'Science',
                          color: Color(0xFFE8F5E9),
                        ),
                      ),
                    ),
                  ),
                  _SubjectCard(
                    title: 'Social Studies',
                    icon: '🌍',
                    color: const Color(0xFFFFF8E1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonsScreen(
                          subject: 'Social Studies',
                          color: Color(0xFFFFF8E1),
                        ),
                      ),
                    ),
                  ),
                  _SubjectCard(
                    title: 'English',
                    icon: '📖',
                    color: const Color(0xFFFCE4EC),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonsScreen(
                          subject: 'English',
                          color: Color(0xFFFCE4EC),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}