import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'teacher_home_screen.dart';
import '../../../app/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('📚', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ಗ್ರಾಮಶಾಲೆ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ನೀವು ಯಾರು?  |  Who are you?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Select your role',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: '🧑‍🎓',
                title: 'ವಿದ್ಯಾರ್ಥಿ',
                subtitle: 'Student',
                description: 'Access lessons, practice quizzes\nand track your progress',
                isSelected: _selectedRole == 'student',
                onTap: () => setState(() => _selectedRole = 'student'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: '👩‍🏫',
                title: 'ಶಿಕ್ಷಕರು',
                subtitle: 'Teacher',
                description: 'Manage content, view student\nprogress and answer doubts',
                isSelected: _selectedRole == 'teacher',
                onTap: () => setState(() => _selectedRole = 'teacher'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRole == null
                      ? null
                      : () async {
                          final box = await Hive.openBox('settings');
                          await box.put('role', _selectedRole);
                          if (context.mounted) {
                            if (_selectedRole == 'student') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StudentSetupScreen(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TeacherLoginScreen(),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text('ಮುಂದುವರಿಯಿರಿ  |  Continue'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Role Card Widget ───────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
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
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ $subtitle',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Student Setup Screen ───────────────────────────────
class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedClass;
  String? _selectedMedium;
  final List<String> _classes = ['8', '9', '10'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Student Setup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            Text(
              'ನಿಮ್ಮ ಬಗ್ಗೆ ಹೇಳಿ',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),

            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name / ನಿಮ್ಮ ಹೆಸರು',
                prefixIcon: const Icon(Icons.person),
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
            const SizedBox(height: 24),

            // Class selection
            Text(
              'Select Class / ತರಗತಿ ಆಯ್ಕೆ ಮಾಡಿ',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _classes.map((cls) {
                final isSelected = _selectedClass == cls;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedClass = cls),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Class $cls',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Medium selection
            Text(
              'Select Medium / ಮಾಧ್ಯಮ ಆಯ್ಕೆ ಮಾಡಿ',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMedium = 'english'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedMedium == 'english'
                            ? AppTheme.primary
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMedium == 'english'
                              ? AppTheme.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('📖',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            'English Medium',
                            style: TextStyle(
                              color: _selectedMedium == 'english'
                                  ? Colors.white
                                  : AppTheme.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMedium = 'kannada'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedMedium == 'kannada'
                            ? AppTheme.primary
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMedium == 'kannada'
                              ? AppTheme.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('🔤',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            'ಕನ್ನಡ ಮಾಧ್ಯಮ',
                            style: TextStyle(
                              color: _selectedMedium == 'kannada'
                                  ? Colors.white
                                  : AppTheme.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_nameController.text.isEmpty ||
                        _selectedClass == null ||
                        _selectedMedium == null)
                    ? null
                    : () async {
                        final box = await Hive.openBox('settings');
                        await box.put(
                            'student_name', _nameController.text);
                        await box.put('student_class', _selectedClass);
                        await box.put('medium', _selectedMedium);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                    'Start Learning / ಕಲಿಕೆ ಪ್ರಾರಂಭಿಸಿ'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Teacher Login Screen ───────────────────────────────
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;
  final String _teacherPassword = 'teacher123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Teacher Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teacher Login',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            Text(
              'ಶಿಕ್ಷಕರ ಲಾಗಿನ್',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password / ಪಾಸ್ವರ್ಡ್',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscure = !_obscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.primary, width: 2),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Default password: teacher123',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_passwordController.text == _teacherPassword) {
                    final box = await Hive.openBox('settings');
                    await box.put('role', 'teacher');
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeacherHomeScreen(),
                        ),
                      );
                    }
                  } else {
                    setState(() => _error = 'Incorrect password!');
                  }
                },
                child: const Text('Login / ಲಾಗಿನ್'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}