import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() =>
      _TeacherProfileScreenState();
}

class _TeacherProfileScreenState
    extends State<TeacherProfileScreen> {
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();
  String? _selectedSubject;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String _teacherId = '';

  final List<Map<String, String>> _subjects = [
    {'name': 'Mathematics', 'icon': '📐'},
    {'name': 'Science', 'icon': '🔬'},
    {'name': 'Social Studies', 'icon': '🌍'},
    {'name': 'English', 'icon': '📖'},
    {'name': 'Kannada', 'icon': '🔤'},
    {'name': 'Hindi', 'icon': '📝'},
    {'name': 'All Subjects', 'icon': '📚'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _nameController.text =
          box.get('teacher_name', defaultValue: '');
      _schoolController.text =
          box.get('teacher_school', defaultValue: '');
      _selectedSubject =
          box.get('teacher_subject', defaultValue: 'Mathematics');
      _teacherId =
          box.get('teacher_id', defaultValue: 'TCH000');
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _schoolController.text.trim().isEmpty) return;

    // Validate password if changed
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Password must be at least 6 characters!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_passwordController.text !=
          _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    final box = await Hive.openBox('settings');
    await box.put(
        'teacher_name', _nameController.text.trim());
    await box.put('teacher_school',
        _schoolController.text.trim());
    await box.put('teacher_subject', _selectedSubject);

    if (_passwordController.text.isNotEmpty) {
      await box.put(
          'teacher_password', _passwordController.text);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated! ✅'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Profile'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _nameController.text
                                      .isNotEmpty
                                  ? _nameController
                                      .text[0]
                                      .toUpperCase()
                                  : 'T',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Text(
                            _teacherId,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name
                  _buildLabel(
                      'Full Name / ಪೂರ್ಣ ಹೆಸರು'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                        'Enter your name', Icons.person),
                  ),
                  const SizedBox(height: 20),

                  // School
                  _buildLabel(
                      'School Name / ಶಾಲೆಯ ಹೆಸರು'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _schoolController,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                        'Enter school name', Icons.school),
                  ),
                  const SizedBox(height: 20),

                  // Subject
                  _buildLabel(
                      'Subject / ವಿಷಯ'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _subjects.map((s) {
                      final isSelected =
                          _selectedSubject == s['name'];
                      return GestureDetector(
                        onTap: () => setState(
                            () => _selectedSubject =
                                s['name']),
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 200),
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : Theme.of(context)
                                    .cardColor,
                            borderRadius:
                                BorderRadius.circular(
                                    24),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.grey[400]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Text(s['icon']!,
                                  style: const TextStyle(
                                      fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                s['name']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
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

                  // Change password section
                  _buildLabel(
                      'Change Password / ಪಾಸ್ವರ್ಡ್ ಬದಲಿಸಿ'),
                  const SizedBox(height: 4),
                  Text(
                    'Leave blank to keep existing password',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure1,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'New password',
                      prefixIcon:
                          const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure1
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _obscure1 = !_obscure1),
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
                            width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller:
                        _confirmPasswordController,
                    obscureText: _obscure2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      prefixIcon: const Icon(
                          Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure2
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _obscure2 = !_obscure2),
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
                            width: 2),
                      ),
                      errorText: _confirmPasswordController
                                  .text.isNotEmpty &&
                              _passwordController.text !=
                                  _confirmPasswordController
                                      .text
                          ? 'Passwords do not match!'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : _saveProfile,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving
                          ? 'Saving...'
                          : 'Save Profile / ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ'),
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
      style:
          Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
    );
  }

  InputDecoration _inputDecoration(
      String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }
}