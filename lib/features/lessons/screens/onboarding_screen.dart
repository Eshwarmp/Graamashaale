import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': '📚',
      'title': 'ಗ್ರಾಮಶಾಲೆಗೆ ಸ್ವಾಗತ!',
      'subtitle': 'Welcome to GraamaShaale!',
      'description':
          'Your complete KSEEB learning companion for Classes 8, 9 and 10. Study anytime, anywhere — even without internet!',
      'description_kn':
          'ತರಗತಿ 8, 9 ಮತ್ತು 10ಕ್ಕೆ ನಿಮ್ಮ ಸಂಪೂರ್ಣ KSEEB ಕಲಿಕಾ ಸಂಗಾತಿ. ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆಯೂ ಕಲಿಯಿರಿ!',
      'color': const Color(0xFF2E7D32),
      'bg': const Color(0xFFE8F5E9),
    },
    {
      'icon': '🔌',
      'title': 'ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಓದಿ',
      'subtitle': 'Read Offline',
      'description':
          'Download KSEEB textbooks once over WiFi and read them forever — no internet needed! Available in both Kannada and English medium.',
      'description_kn':
          'WiFi ಮೂಲಕ KSEEB ಪಠ್ಯಪುಸ್ತಕಗಳನ್ನು ಒಮ್ಮೆ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ, ಯಾವಾಗಲೂ ಓದಿ! ಕನ್ನಡ ಮತ್ತು ಇಂಗ್ಲಿಷ್ ಮಾಧ್ಯಮ ಲಭ್ಯ.',
      'color': const Color(0xFF1565C0),
      'bg': const Color(0xFFE3F2FD),
    },
    {
      'icon': '👩‍🏫',
      'title': 'ಶಿಕ್ಷಕರೊಂದಿಗೆ ಸಂಪರ್ಕ',
      'subtitle': 'Connect with Teachers',
      'description':
          'Ask doubts anytime — they get saved offline and sent to your teacher when internet is available. Practice quizzes and track your progress!',
      'description_kn':
          'ಯಾವಾಗಲೂ ಸಂಶಯ ಕೇಳಿ — ಅವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಉಳಿಸಲ್ಪಡುತ್ತವೆ ಮತ್ತು ಇಂಟರ್ನೆಟ್ ಸಿಕ್ಕಾಗ ಶಿಕ್ಷಕರಿಗೆ ತಲುಪುತ್ತವೆ!',
      'color': const Color(0xFFF9A825),
      'bg': const Color(0xFFFFF8E1),
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final box = await Hive.openBox('settings');
    await box.put('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip / ಬಿಟ್ಟುಬಿಡಿ',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPage(page: page);
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _pages[_currentPage]['color']
                            as Color
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _pages[_currentPage]['color']
                            as Color,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Next / ಮುಂದೆ →'
                        : 'Get Started / ಪ್ರಾರಂಭಿಸಿ 🚀',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Map<String, dynamic> page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page['bg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page['icon'] as String,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Kannada title
          Text(
            page['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: page['color'] as Color,
            ),
          ),
          const SizedBox(height: 4),

          // English subtitle
          Text(
            page['subtitle'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

          // Kannada description
          Text(
            page['description_kn'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}