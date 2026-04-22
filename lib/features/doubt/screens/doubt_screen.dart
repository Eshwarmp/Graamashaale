import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/doubt_model.dart';
import '../../../core/theme/app_theme.dart';

class DoubtScreen extends StatefulWidget {
  const DoubtScreen({super.key});

  @override
  State<DoubtScreen> createState() => _DoubtScreenState();
}

class _DoubtScreenState extends State<DoubtScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  final _doubtController = TextEditingController();
  String _selectedSubject = 'Mathematics';
  List<Doubt> _doubts = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<Map<String, String>> _subjects = [
    {'name': 'Mathematics', 'icon': '📐'},
    {'name': 'Science', 'icon': '🔬'},
    {'name': 'Social Studies', 'icon': '🌍'},
    {'name': 'English', 'icon': '📖'},
    {'name': 'Kannada', 'icon': '🔤'},
    {'name': 'Hindi', 'icon': '📝'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDoubts();
  }

  Future<void> _loadDoubts() async {
    final doubts = await _repo.getAllDoubts();
    setState(() {
      _doubts = doubts;
      _isLoading = false;
    });
  }

  Future<void> _submitDoubt() async {
    if (_doubtController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    await _repo.saveDoubt(Doubt(
      subject: _selectedSubject,
      question: _doubtController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    ));

    _doubtController.clear();
    await _loadDoubts();

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doubt submitted! ✅'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Doubt Corner / ಸಂಶಯ ಮೂಲೆ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💡',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ask your doubt — it will be saved and sent to your teacher when internet is available.\nನಿಮ್ಮ ಸಂಶಯ ಕೇಳಿ — ಇಂಟರ್ನೆಟ್ ಸಿಕ್ಕಾಗ ಶಿಕ್ಷಕರಿಗೆ ತಲುಪಿಸಲಾಗುತ್ತದೆ.',
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
                  const SizedBox(height: 24),

                  // Subject selection
                  Text(
                    'Select Subject / ವಿಷಯ ಆಯ್ಕೆ ಮಾಡಿ',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        final isSelected =
                            _selectedSubject == subject['name'];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedSubject =
                                  subject['name']!),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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
                              children: [
                                Text(subject['icon']!,
                                    style: const TextStyle(
                                        fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  subject['name']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Doubt input
                  Text(
                    'Your Doubt / ನಿಮ್ಮ ಸಂಶಯ',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _doubtController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Type your doubt here...\nನಿಮ್ಮ ಸಂಶಯ ಇಲ್ಲಿ ಬರೆಯಿರಿ...',
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
                      filled: true,
                      fillColor: AppTheme.surface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSubmitting ? null : _submitDoubt,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isSubmitting
                          ? 'Submitting...'
                          : 'Submit Doubt / ಸಂಶಯ ಕಳಿಸಿ'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Previous doubts
                  if (_doubts.isNotEmpty) ...[
                    Text(
                      'My Previous Doubts / ಹಿಂದಿನ ಸಂಶಯಗಳು',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    ..._doubts.map((doubt) => _DoubtCard(
                          doubt: doubt,
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}

class _DoubtCard extends StatelessWidget {
  final Doubt doubt;

  const _DoubtCard({required this.doubt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doubt.subject,
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
                  color: doubt.isSynced
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      doubt.isSynced
                          ? Icons.check_circle
                          : Icons.schedule,
                      size: 12,
                      color: doubt.isSynced
                          ? AppTheme.primary
                          : AppTheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doubt.isSynced
                          ? 'Answered'
                          : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: doubt.isSynced
                            ? AppTheme.primary
                            : AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question
          Text(
            '❓ ${doubt.question}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppTheme.textDark,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            doubt.createdAt.substring(0, 10),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),

          // Show teacher's answer if available
          if (doubt.isSynced &&
              doubt.answer != null &&
              doubt.answer!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👩‍🏫 Teacher\'s Answer:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    doubt.answer!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!doubt.isSynced) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Waiting for teacher\'s answer...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
