import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final DownloadService instance = DownloadService._internal();
  DownloadService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      followRedirects: true,
      maxRedirects: 5,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: {
        'User-Agent': 'GraamaShaale-App',
      },
    ),
  );

  // Get local path for a PDF
  Future<String> getLocalPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = fileName.split('/').last;
    return '${dir.path}/$name';
  }

  // Check if PDF already downloaded
  Future<bool> isDownloaded(String fileName) async {
    final localPath = await getLocalPath(fileName);
    return File(localPath).exists();
  }

  // Download PDF from GitHub Releases
  Future<String?> downloadPdf(
    String url,
    String fileName, {
    Function(double)? onProgress,
  }) async {
    try {
      final localPath = await getLocalPath(fileName);
      final file = File(localPath);

      if (await file.exists()) return localPath;

      print('⬇️ Downloading: $url');
      print('💾 Saving to: $localPath');

      await _dio.download(
        url,
        localPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress?.call(received / total);
          }
        },
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (await file.exists() && await file.length() > 1000) {
        print('✅ Downloaded successfully: ${await file.length()} bytes');
        return localPath;
      } else {
        print('❌ File too small or missing');
        if (await file.exists()) await file.delete();
        return null;
      }
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }

  // Delete a downloaded PDF
  Future<void> deletePdf(String fileName) async {
    final localPath = await getLocalPath(fileName);
    final file = File(localPath);
    if (await file.exists()) await file.delete();
  }

  // Get total downloaded size
  Future<String> getDownloadedSize() async {
    final dir = await getApplicationDocumentsDirectory();
    int totalBytes = 0;
    await for (final file in dir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.pdf')) {
        totalBytes += await file.length();
      }
    }
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}