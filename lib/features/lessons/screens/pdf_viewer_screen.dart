import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/lesson_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/sync/download_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../practice/screens/quiz_screen.dart';

class PdfViewerScreen extends StatefulWidget {
  final Lesson lesson;

  const PdfViewerScreen({super.key, required this.lesson});

  @override
  State<PdfViewerScreen> createState() =>
      _PdfViewerScreenState();
}

class _PdfViewerScreenState
    extends State<PdfViewerScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  String? _localPath;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _downloadProgress = 0;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final box = await Hive.openBox('settings');
      final medium =
          box.get('medium', defaultValue: 'english');
      final pdfUrl = widget.lesson.getPdfPath(medium);
      final fileName = pdfUrl.split('/').last;

      final isDownloaded =
          await DownloadService.instance
              .isDownloaded(fileName);

      if (isDownloaded) {
        final localPath = await DownloadService.instance
            .getLocalPath(fileName);
        setState(() {
          _localPath = localPath;
          _isLoading = false;
        });
        await _repo.updateStreak();
        return;
      }

      final isOnline =
          await SyncService.instance.isConnected();
      if (!isOnline) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No internet connection!';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isDownloading = true;
        _isLoading = false;
      });

      final localPath =
          await DownloadService.instance.downloadPdf(
        pdfUrl,
        fileName,
        onProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      if (localPath != null) {
        setState(() {
          _localPath = localPath;
          _isDownloading = false;
        });
        await _repo.updateStreak();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Download failed! Please try again.';
          _isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${_currentPage + 1}/$_totalPages',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.quiz,
                color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    QuizScreen(lesson: widget.lesson),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : _isDownloading
              ? _buildDownloadProgress()
              : _hasError
                  ? _buildError()
                  : _buildPdfView(),
    );
  }

  Widget _buildDownloadProgress() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📥',
                style: TextStyle(fontSize: 60)),
            const SizedBox(height: 24),
            Text(
              'Downloading textbook...',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'ಪಠ್ಯಪುಸ್ತಕ ಡೌನ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
              style:
                  TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _downloadProgress > 0
                    ? _downloadProgress
                    : null,
                backgroundColor:
                    Theme.of(context).brightness ==
                            Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[200],
                color: AppTheme.primary,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _downloadProgress > 0
                  ? '${(_downloadProgress * 100).toStringAsFixed(0)}%'
                  : 'Connecting...',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved for offline use after download ✅',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📡',
                style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              _errorMessage.contains('internet')
                  ? 'No internet connection!'
                  : 'Download failed!',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.contains('internet')
                  ? 'Please connect to internet to download this textbook for the first time.\n\nOnce downloaded, works offline forever! ✅'
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                  _downloadProgress = 0;
                });
                _loadPdf();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfView() {
    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onRender: (pages) =>
              setState(() => _totalPages = pages!),
          onPageChanged: (page, total) =>
              setState(() => _currentPage = page!),
          onViewCreated: (controller) =>
              _pdfController = controller,
          onError: (error) =>
              setState(() => _hasError = true),
        ),

        // Bottom bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (!widget.lesson.isCompleted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _repo.markLessonCompleted(
                            widget.lesson.id!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Marked as completed! ✅'),
                              backgroundColor:
                                  AppTheme.primary,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label:
                          const Text('Mark Complete'),
                    ),
                  ),
                if (widget.lesson.isCompleted)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Completed!',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                          lesson: widget.lesson),
                    ),
                  ),
                  icon: const Icon(Icons.quiz),
                  label: const Text('Quiz'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                        color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}