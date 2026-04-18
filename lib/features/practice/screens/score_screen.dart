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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: resultColor,
                  width: 4,
                ),
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
            const SizedBox(height: 32),

            // Result label
            Text(
              resultLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
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
            const SizedBox(height: 48),

            // Stats card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Correct',
                    value: '$score',
                    color: const Color(0xFF2E7D32),
                  ),
                  _StatItem(
                    label: 'Wrong',
                    value: '${total - score}',
                    color: const Color(0xFFC62828),
                  ),
                  _StatItem(
                    label: 'Total',
                    value: '$total',
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Go home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
            ),
            const SizedBox(height: 12),

            // Try again button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ],
    );
  }
}