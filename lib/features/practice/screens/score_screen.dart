import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/main_screen.dart';

class ScoreScreen extends StatelessWidget {
  final int score;
  final int total;
  final String lessonTitle;

  const ScoreScreen({
    super.key,
    required this.score,
    required this.total,
    required this.lessonTitle,
  });

  double get _percentage =>
      total == 0 ? 0 : (score / total) * 100;

  String get _resultLabel {
    if (_percentage >= 80) return 'Excellent! 🌟';
    if (_percentage >= 60) return 'Good Job! 👍';
    if (_percentage >= 40) return 'Keep Practicing! 💪';
    return 'Try Again! 📖';
  }

  String get _resultLabelKn {
    if (_percentage >= 80) return 'ಅತ್ಯುತ್ತಮ! 🌟';
    if (_percentage >= 60) return 'ಚೆನ್ನಾಗಿದೆ! 👍';
    if (_percentage >= 40) return 'ಮತ್ತಷ್ಟು ಅಭ್ಯಾಸ ಮಾಡಿ! 💪';
    return 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ! 📖';
  }

  Color get _scoreColor {
    if (_percentage >= 80)
      return const Color(0xFF2E7D32);
    if (_percentage >= 60)
      return const Color(0xFF1565C0);
    if (_percentage >= 40)
      return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Score circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _scoreColor.withValues(alpha: 0.1),
                border: Border.all(
                    color: _scoreColor, width: 4),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    '$score/$total',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor,
                    ),
                  ),
                  Text(
                    '${_percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: _scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Result label
            Text(
              _resultLabel,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _scoreColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _resultLabelKn,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lessonTitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 32),

            // Stats card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    value: '$score',
                    label: 'Correct',
                    labelKn: 'ಸರಿ',
                    color: const Color(0xFF2E7D32),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Theme.of(context).dividerColor,
                  ),
                  _StatItem(
                    value: '${total - score}',
                    label: 'Wrong',
                    labelKn: 'ತಪ್ಪು',
                    color: const Color(0xFFC62828),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Theme.of(context).dividerColor,
                  ),
                  _StatItem(
                    value: '$total',
                    label: 'Total',
                    labelKn: 'ಒಟ್ಟು',
                    color: const Color(0xFF1565C0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Suggestion card
            if (_percentage < 60)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF9A825)
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('📖',
                        style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Review the textbook and try again!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const Text(
                            'ಪಠ್ಯಪುಸ್ತಕ ಓದಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to MainScreen (with bottom nav bar)
                  // and clear the entire navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const MainScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text(
                    'Back to Home / ಮುಖಪುಟಕ್ಕೆ'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text(
                    'Try Again / ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(
                      color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String labelKn;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.labelKn,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          labelKn,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}