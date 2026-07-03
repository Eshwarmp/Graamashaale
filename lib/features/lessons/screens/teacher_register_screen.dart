import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'teacher_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() =>
      _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState
    extends State<TeacherRegisterScreen> {
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  String? _selectedSubject;
  String? _error;

  final List<Map<String, String>> _subjects = [
    {'name': 'Mathematics', 'icon': '📐'},
    {'name': 'Science', 'icon': '🔬'},
    {'name': 'Social Studies', 'icon': '🌍'},
    {'name': 'English', 'icon': '📖'},
    {'name': 'Kannada', 'icon': '🔤'},
    {'name': 'Hindi', 'icon': '📝'},
    {'name': 'All Subjects', 'icon': '📚'},
  ];

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _schoolController.text.isNotEmpty &&
      _passwordController.text.length >= 6 &&
      _passwordController.text ==
          _confirmPasswordController.text &&
      _selectedSubject != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Teacher Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        '👩‍🏫',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create Teacher Account',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                  ),
                  Text(
                    'ಶಿಕ್ಷಕರ ಖಾತೆ ತೆರೆಯಿರಿ',
                    style:
                        TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name Field
            _buildLabel('Full Name / ಪೂರ್ಣ ಹೆಸರು'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person,
            ),

            const SizedBox(height: 20),

            // School Field
            _buildLabel('School Name / ಶಾಲೆಯ ಹೆಸರು'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _schoolController,
              hint: 'Enter your school name',
              icon: Icons.school,
            ),

            const SizedBox(height: 20),

            // Subject Selection
            _buildLabel(
              'Subject You Teach / ನೀವು ಕಲಿಸುವ ವಿಷಯ',
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((s) {
                final isSelected =
                    _selectedSubject == s['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSubject = s['name'];
                    });
                  },
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s['icon']!,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s['name']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark,
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Password Field
            _buildLabel('Password / ಪಾಸ್ವರ್ಡ್'),
            const SizedBox(height: 8),

            TextField(
              controller: _passwordController,
              obscureText: _obscure1,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Minimum 6 characters',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure1
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure1 = !_obscure1;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Confirm Password
            _buildLabel(
              'Confirm Password / ಪಾಸ್ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
            ),
            const SizedBox(height: 8),

            TextField(
              controller:
                  _confirmPasswordController,
              obscureText: _obscure2,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Re-enter password',
                prefixIcon:
                    const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure2
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure2 = !_obscure2;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
                errorText:
                    _confirmPasswordController
                                .text
                                .isNotEmpty &&
                            _passwordController.text !=
                                _confirmPasswordController
                                    .text
                        ? 'Passwords do not match!'
                        : null,
              ),
            ),

            // Error Message
            if (_error != null) ...[
              const SizedBox(height: 12),

              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isFormValid ? _register : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor:
                      Colors.grey[300],
                ),
                child: const Text(
                  'Register / ನೋಂದಾಯಿಸಿ',
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final box = await Hive.openBox('settings');

    final teacherId =
        'TCH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    await box.put('role', 'teacher');
    await box.put(
      'teacher_name',
      _nameController.text.trim(),
    );
    await box.put(
      'teacher_school',
      _schoolController.text.trim(),
    );
    await box.put(
      'teacher_subject',
      _selectedSubject,
    );
    await box.put(
      'teacher_password',
      _passwordController.text,
    );
    await box.put('teacher_id', teacherId);

    // Save to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherId)
          .set({
        'teacher_id': teacherId,
        'name': _nameController.text.trim(),
        'school':
            _schoolController.text.trim(),
        'subject': _selectedSubject,
        'registered_at':
            DateTime.now().toIso8601String(),
      });
    } catch (e) {
      setState(() {
        _error =
            'Failed to save online. Saved locally only.';
      });
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const TeacherHomeScreen(),
        ),
        (route) => false,
      );
    }
  }
}