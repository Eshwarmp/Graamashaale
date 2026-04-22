import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/doubt_model.dart';
import 'login_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  int _totalDoubts = 0;
  int _pendingDoubts = 0;
  int _completedLessons = 0;
  int _totalQuizzes = 0;
  List<Doubt> _doubts = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allDoubts = await _repo.getAllDoubts();
    final unsyncedDoubts = await _repo.getUnsyncedDoubts();
    final allProgress = await _repo.getAllProgress();

    final subjects = [
      'Mathematics', 'Science', 'Social Studies',
      'English', 'Kannada', 'Hindi'
    ];
    int completed = 0;
    for (final subject in subjects) {
      completed += await _repo.getCompletedCount(subject);
    }

    setState(() {
      _totalDoubts = allDoubts.length;
      _pendingDoubts = unsyncedDoubts.length;
      _doubts = allDoubts;
      _completedLessons = completed;
      _totalQuizzes = allProgress.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final box = await Hive.openBox('settings');
              await box.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tab bar
                Container(
                  color: AppTheme.primary,
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'Overview',
                        icon: Icons.dashboard,
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      _TabButton(
                        label: 'Doubts',
                        icon: Icons.question_answer,
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                        badge: _pendingDoubts,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedTab == 0
                      ? _buildOverview()
                      : _buildDoubts(),
                ),
              ],
            ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ನಮಸ್ಕಾರ, ಶಿಕ್ಷಕರೇ! 👩‍🏫',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome, Teacher!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'GraamaShaale — KSEEB Karnataka 📚',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Text(
            'Student Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                icon: '📚',
                value: '$_completedLessons',
                label: 'Textbooks\nCompleted',
                color: const Color(0xFFE8F5E9),
              ),
              _StatCard(
                icon: '📝',
                value: '$_totalQuizzes',
                label: 'Quizzes\nAttempted',
                color: const Color(0xFFE3F2FD),
              ),
              _StatCard(
                icon: '❓',
                value: '$_totalDoubts',
                label: 'Total\nDoubts',
                color: const Color(0xFFFFF8E1),
              ),
              _StatCard(
                icon: '🔔',
                value: '$_pendingDoubts',
                label: 'Pending\nDoubts',
                color: const Color(0xFFFFEBEE),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subjects overview
          Text(
            'Subjects',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 16),
          ...[
            {'subject': 'Mathematics', 'icon': '📐', 'color': const Color(0xFFE3F2FD)},
            {'subject': 'Science', 'icon': '🔬', 'color': const Color(0xFFE8F5E9)},
            {'subject': 'Social Studies', 'icon': '🌍', 'color': const Color(0xFFFFF8E1)},
            {'subject': 'English', 'icon': '📖', 'color': const Color(0xFFFCE4EC)},
            {'subject': 'Kannada', 'icon': '🔤', 'color': const Color(0xFFEDE7F6)},
            {'subject': 'Hindi', 'icon': '📝', 'color': const Color(0xFFFFF3E0)},
          ].map((s) => _SubjectRow(
                subject: s['subject'] as String,
                icon: s['icon'] as String,
                color: s['color'] as Color,
                repo: _repo,
              )),
        ],
      ),
    );
  }

  Widget _buildDoubts() {
    if (_doubts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❓', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'No doubts yet!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Student doubts will appear here.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _doubts.length,
      itemBuilder: (context, index) {
        final doubt = _doubts[index];
        return _DoubtCard(
          doubt: doubt,
          repo: _repo,
          onAnswered: _loadData,
        );
      },
    );
  }
}

// ── Tab Button ──────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badge;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ───────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Subject Row ─────────────────────────────────────────
class _SubjectRow extends StatefulWidget {
  final String subject;
  final String icon;
  final Color color;
  final DatabaseRepository repo;

  const _SubjectRow({
    required this.subject,
    required this.icon,
    required this.color,
    required this.repo,
  });

  @override
  State<_SubjectRow> createState() => _SubjectRowState();
}

class _SubjectRowState extends State<_SubjectRow> {
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await widget.repo.getCompletedCount(widget.subject);
    setState(() => _completed = count);
  }

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(widget.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.subject,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _completed > 0
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_completed completed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _completed > 0
                    ? AppTheme.primary
                    : AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doubt Card ──────────────────────────────────────────
class _DoubtCard extends StatefulWidget {
  final Doubt doubt;
  final DatabaseRepository repo;
  final VoidCallback onAnswered;

  const _DoubtCard({
    required this.doubt,
    required this.repo,
    required this.onAnswered,
  });

  @override
  State<_DoubtCard> createState() => _DoubtCardState();
}

class _DoubtCardState extends State<_DoubtCard> {
  final _answerController = TextEditingController();
  bool _isReplying = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.doubt.isSynced
              ? Colors.transparent
              : AppTheme.secondary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
                  widget.doubt.subject,
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
                  color: widget.doubt.isSynced
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.doubt.isSynced ? '✅ Answered' : '🔔 Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.doubt.isSynced
                        ? AppTheme.primary
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question
          Text(
            '❓ ${widget.doubt.question}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDark,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            widget.doubt.createdAt.substring(0, 10),
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),

          // Show existing answer
          if (widget.doubt.isSynced &&
              widget.doubt.answer != null &&
              widget.doubt.answer!.isNotEmpty) ...[
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
                    widget.doubt.answer!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Reply section
          if (!widget.doubt.isSynced) ...[
            const SizedBox(height: 12),
            if (!_isReplying)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isReplying = true),
                  icon: const Icon(Icons.reply),
                  label: const Text('Reply / ಉತ್ತರಿಸಿ'),
                ),
              )
            else ...[
              TextField(
                controller: _answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Type your answer...\nನಿಮ್ಮ ಉತ್ತರ ಬರೆಯಿರಿ...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _isReplying = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_answerController.text
                                  .trim()
                                  .isEmpty) return;
                              setState(() => _isSubmitting = true);
                              await widget.repo.answerDoubt(
                                widget.doubt.id!,
                                _answerController.text.trim(),
                              );
                              widget.onAnswered();
                              setState(() {
                                _isSubmitting = false;
                                _isReplying = false;
                              });
                            },
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Send Answer'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}