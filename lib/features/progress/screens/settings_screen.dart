import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/app.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  String? _selectedClass;
  String? _selectedMedium;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _classes = ['8', '9', '10'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _nameController.text =
          box.get('student_name', defaultValue: '');
      _selectedClass =
          box.get('student_class', defaultValue: '9');
      _selectedMedium =
          box.get('medium', defaultValue: 'english');
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final box = await Hive.openBox('settings');
    await box.put(
        'student_name', _nameController.text.trim());
    await box.put('student_class', _selectedClass);
    await box.put('medium', _selectedMedium);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved! ✅'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings / ಸೆಟ್ಟಿಂಗ್ಸ್'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary
                          .withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('⚙️',
                            style:
                                TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Update your profile and learning preferences.\nನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಮತ್ತು ಕಲಿಕಾ ಆದ್ಯತೆಗಳನ್ನು ಬದಲಾಯಿಸಿ.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name
                  _buildLabel(
                      'Your Name / ನಿಮ್ಮ ಹೆಸರು'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon:
                          const Icon(Icons.person),
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
                  const SizedBox(height: 28),

                  // Class
                  _buildLabel('Class / ತರಗತಿ'),
                  const SizedBox(height: 12),
                  Row(
                    children: _classes.map((cls) {
                      final isSelected =
                          _selectedClass == cls;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() =>
                              _selectedClass = cls),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            margin: const EdgeInsets
                                .only(right: 12),
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Theme.of(context)
                                      .cardColor,
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
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
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Medium
                  _buildLabel('Medium / ಮಾಧ್ಯಮ'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() =>
                              _selectedMedium = 'english'),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedMedium ==
                                      'english'
                                  ? AppTheme.primary
                                  : Theme.of(context)
                                      .cardColor,
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                              border: Border.all(
                                color: _selectedMedium ==
                                        'english'
                                    ? AppTheme.primary
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text('📖',
                                    style: TextStyle(
                                        fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  'English Medium',
                                  style: TextStyle(
                                    color: _selectedMedium ==
                                            'english'
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    fontWeight:
                                        FontWeight.w700,
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
                          onTap: () => setState(() =>
                              _selectedMedium = 'kannada'),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedMedium ==
                                      'kannada'
                                  ? AppTheme.primary
                                  : Theme.of(context)
                                      .cardColor,
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                              border: Border.all(
                                color: _selectedMedium ==
                                        'kannada'
                                    ? AppTheme.primary
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text('🔤',
                                    style: TextStyle(
                                        fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  'ಕನ್ನಡ ಮಾಧ್ಯಮ',
                                  style: TextStyle(
                                    color: _selectedMedium ==
                                            'kannada'
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    fontWeight:
                                        FontWeight.w700,
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
                  const SizedBox(height: 28),

                  // Dark mode toggle
                  _buildLabel('Appearance / ನೋಟ'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          isDark ? '🌙' : '☀️',
                          style: const TextStyle(
                              fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDark
                                    ? 'Dark Mode'
                                    : 'Light Mode',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              Text(
                                isDark
                                    ? 'ಡಾರ್ಕ್ ಮೋಡ್'
                                    : 'ಲೈಟ್ ಮೋಡ್',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isDark,
                          activeColor: AppTheme.primary,
                          onChanged: (val) async {
                            ref
                                .read(themeModeProvider
                                    .notifier)
                                .state = val
                                ? ThemeMode.dark
                                : ThemeMode.light;
                            final box = await Hive
                                .openBox('settings');
                            await box.put(
                                'dark_mode', val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // App info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: '📱',
                          label: 'App Version',
                          value: 'v1.0.0',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: '🎓',
                          label: 'Curriculum',
                          value: 'KSEEB Karnataka',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: '📚',
                          label: 'Classes',
                          value: '8, 9 and 10',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: '🌐',
                          label: 'Languages',
                          value: 'Kannada & English',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _nameController.text
                                      .trim()
                                      .isEmpty ||
                                  _isSaving
                              ? null
                              : _saveSettings,
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
                          : 'Save Changes / ಬದಲಾವಣೆ ಉಳಿಸಿ'),
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
}

class _InfoRow extends StatelessWidget {
  final String icon;
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
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color:
                Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}