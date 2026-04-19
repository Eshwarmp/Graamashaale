import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../lessons/screens/home_screen.dart';

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

  double get percentage => total == 0 ? 0 : (score / total) * 100;

  String get resultLabel {
    if (percentage >= 80) return 'Excellent! 🎉';
    if (percentage >= 60) return 'Good Job! 👍';
    if (percentage >= 40) return 'Keep Practicing! 💪';
    return 'Needs Improvement 📚';
  }

  String get resultLabelKannada {
    if (percentage >= 80) return 'ಅತ್ಯುತ್ತಮ! 🎉';
    if (percentage >= 60) return 'ಭಲೇ! 👍';
    if (percentage >= 40) return 'ಮತ್ತಷ್ಟು ಅಭ್ಯಾಸ ಮಾಡಿ! 💪';
    return 'ಇನ್ನಷ್ಟು ಓದಬೇಕು 📚';
  }

  Color get resultColor {
    if (percentage >= 80) return const Color(0xFF2E7D32);
    if (percentage >= 60) return const Color(0xFF1565C0);
    if (percentage >= 40) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Score circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: resultColor, width: 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score/$total',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: resultColor,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      color: resultColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Result labels
            Text(
              resultLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              resultLabelKannada,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lessonTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Stats card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Correct\nಸರಿ',
                    value: '$score',
                    color: const Color(0xFF2E7D32),
                  ),
                  _StatItem(
                    label: 'Wrong\nತಪ್ಪು',
                    value: '${total - score}',
                    color: const Color(0xFFC62828),
                  ),
                  _StatItem(
                    label: 'Total\nಒಟ್ಟು',
                    value: '$total',
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Motivational message
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
              child: Text(
                percentage >= 80
                    ? '🌟 You\'re doing great! Keep it up!\nನೀವು ತುಂಬಾ ಚೆನ್ನಾಗಿ ಮಾಡುತ್ತಿದ್ದೀರಿ!'
                    : '📖 Review the textbook and try again!\nಪಠ್ಯಪುಸ್ತಕ ಓದಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home / ಮುಖಪುಟಕ್ಕೆ'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again / ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ'),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}