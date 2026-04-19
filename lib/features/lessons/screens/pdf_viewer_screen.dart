import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/database/database_repository.dart';
import '../../../core/database/lesson_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../practice/screens/quiz_screen.dart';

class PdfViewerScreen extends StatefulWidget {
  final Lesson lesson;

  const PdfViewerScreen({super.key, required this.lesson});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final DatabaseRepository _repo = DatabaseRepository();
  String? _localPath;
  bool _isLoading = true;
  bool _hasError = false;
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
      // Load PDF from assets
      final byteData =
          await rootBundle.load(widget.lesson.pdfPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.lesson.pdfPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          // Page indicator
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${_currentPage + 1}/$_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          // Quiz button
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(lesson: widget.lesson),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading textbook...'),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📄',
                          style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        'Textbook not found!',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please add the PDF file to:\n${widget.lesson.pdfPath}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                          });
                          _loadPdf();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // PDF viewer
                    PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      onRender: (pages) {
                        setState(() => _totalPages = pages!);
                      },
                      onPageChanged: (page, total) {
                        setState(() => _currentPage = page!);
                      },
                      onViewCreated: (controller) {
                        _pdfController = controller;
                      },
                      onError: (error) {
                        setState(() => _hasError = true);
                      },
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
                          color: AppTheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Mark complete button
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
                            // Quiz button
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                        lesson: widget.lesson),
                                  ),
                                );
                              },
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
                ),
    );
  }
}