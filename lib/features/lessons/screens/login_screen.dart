import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/main_screen.dart';
import 'teacher_home_screen.dart';
import 'teacher_register_screen.dart';

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
                description:
                    'Access lessons, practice quizzes\nand track your progress',
                isSelected: _selectedRole == 'student',
                onTap: () => setState(() => _selectedRole = 'student'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: '👩‍🏫',
                title: 'ಶಿಕ್ಷಕರು',
                subtitle: 'Teacher',
                description:
                    'Manage content, view student\nprogress and answer doubts',
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
                              // push (not pushReplacement) keeps this
                              // role-selection screen on the stack, so
                              // pressing back from Student Setup returns
                              // here instead of exiting the app.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StudentSetupScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
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

// ─── Role Card ──────────────────────────────────────────
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
              : Theme.of(context).cardColor,
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
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
              Icon(Icons.check_circle,
                  color: AppTheme.primary, size: 24),
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
  State<StudentSetupScreen> createState() =>
      _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedClass;
  String? _selectedMedium;
  bool _isChecking = false;
  bool _nameTaken = false;
  String _takenBy = '';
  final List<String> _classes = ['8', '9', '10'];

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedClass != null &&
      _selectedMedium != null &&
      !_nameTaken &&
      !_isChecking;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Check if name+class is already taken by another student
  Future<void> _checkNameAvailability() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedClass == null) return;

    setState(() {
      _isChecking = true;
      _nameTaken = false;
      _takenBy = '';
    });

    final box = await Hive.openBox('settings');
    final rawHistory =
        box.get('student_history', defaultValue: <dynamic, dynamic>{});
    final historyMap = Map<String, String>.from(
        rawHistory.map((k, v) => MapEntry(k.toString(), v.toString())));

    final key = '${name.toLowerCase()}_$_selectedClass';

    if (historyMap.containsKey(key)) {
      // This name+class combo exists — check if it's on THIS device
      // We allow re-login for same student, but warn it's taken
      setState(() {
        _nameTaken = true;
        _takenBy = 'This name is already registered for Class $_selectedClass on this device. If this is you, tap Continue to log back in. Otherwise choose a different name.';
        _isChecking = false;
      });
    } else {
      setState(() {
        _nameTaken = false;
        _takenBy = '';
        _isChecking = false;
      });
    }
  }

  Future<void> _startLearning() async {
    final box = await Hive.openBox('settings');
    final name = _nameController.text.trim();

    final rawHistory =
        box.get('student_history', defaultValue: <dynamic, dynamic>{});
    final historyMap = Map<String, String>.from(
        rawHistory.map((k, v) => MapEntry(k.toString(), v.toString())));

    final key = '${name.toLowerCase()}_$_selectedClass';

    String studentId;
    if (historyMap.containsKey(key)) {
      // Returning student — reuse their existing ID
      studentId = historyMap[key]!;
    } else {
      // New student — generate a fresh unique ID
      studentId =
          'STU${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      historyMap[key] = studentId;
      await box.put('student_history', historyMap);
    }

    await box.put('student_name', name);
    await box.put('student_class', _selectedClass);
    await box.put('medium', _selectedMedium);
    await box.put('student_id', studentId);

    // Save to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .set({
        'student_id': studentId,
        'name': name,
        'class': _selectedClass,
        'medium': _selectedMedium,
        'registered_at': DateTime.now().toIso8601String(),
        'last_login': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail if offline
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Setup')),
      // SingleChildScrollView + explicit bottom padding for the keyboard
      // (viewInsets.bottom) means the content scrolls instead of
      // overflowing when the keyboard opens for the name field.
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
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
              onChanged: (_) {
                setState(() {
                  _nameTaken = false;
                  _takenBy = '';
                });
              },
              onEditingComplete: _checkNameAvailability,
              decoration: InputDecoration(
                labelText: 'Your Name / ನಿಮ್ಮ ಹೆಸರು',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: _isChecking
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : _nameTaken
                        ? const Icon(Icons.warning_amber,
                            color: Colors.orange)
                        : _nameController.text.isNotEmpty &&
                                _selectedClass != null &&
                                !_isChecking
                            ? Icon(Icons.check_circle,
                                color: AppTheme.primary)
                            : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _nameTaken
                        ? Colors.orange
                        : AppTheme.primary,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _nameTaken
                        ? Colors.orange
                        : Colors.grey[400]!,
                  ),
                ),
              ),
            ),

            // Name taken warning
            if (_nameTaken) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _takenBy,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                    onTap: () {
                      setState(() => _selectedClass = cls);
                      // Re-check availability when class changes
                      if (_nameController.text.isNotEmpty) {
                        _checkNameAvailability();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Class $cls',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedMedium == 'english'
                            ? AppTheme.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMedium == 'english'
                              ? AppTheme.primary
                              : Colors.grey[400]!,
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
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedMedium == 'kannada'
                            ? AppTheme.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMedium == 'kannada'
                              ? AppTheme.primary
                              : Colors.grey[400]!,
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
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
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
            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormValid ? _startLearning : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey[300],
                  // Orange tint if name is taken but user wants to re-login
                  backgroundColor:
                      _nameTaken ? Colors.orange : AppTheme.primary,
                ),
                child: Text(
                  _nameTaken
                      ? 'Continue as Eshwar / ಮುಂದುವರಿಯಿರಿ'
                      : 'Start Learning / ಕಲಿಕೆ ಪ್ರಾರಂಭಿಸಿ',
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

// ─── Teacher Login Screen ───────────────────────────────
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() =>
      _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final box = await Hive.openBox('settings');
    final savedPassword =
        box.get('teacher_password', defaultValue: 'teacher123');

    if (_passwordController.text == savedPassword) {
      await box.put('role', 'teacher');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherHomeScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _error = 'Incorrect password!';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      child: Text('👩‍🏫',
                          style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Teacher Login',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'ಶಿಕ್ಷಕರ ಲಾಗಿನ್',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Text(
              'Password / ಪಾಸ್ವರ್ಡ್',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Enter your password',
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
              style:
                  TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login / ಲಾಗಿನ್'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherRegisterScreen(),
                  ),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text(
                    'New Teacher? Register / ನೋಂದಣಿ ಮಾಡಿ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary),
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