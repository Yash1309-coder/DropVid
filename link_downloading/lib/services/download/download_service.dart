import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_config.dart';

/// File download service with progress tracking
class DownloadService {
  final Dio _dio = Dio();

  /// Download a file from a direct URL
  /// Returns the local file path where the file was saved
  /// [onProgress] reports 0.0 to 1.0
  Future<String> downloadFile({
    required String downloadUrl,
    required String fileName,
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _getDownloadDirectory();
    final filePath = '${dir.path}/$fileName';

    await _dio.download(
      downloadUrl,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    // Verify file exists and has content
    final file = File(filePath);
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('Download failed. File may be corrupted.');
    }

    return filePath;
  }

  /// Get the download directory
  Future<Directory> _getDownloadDirectory() async {
    Directory? dir;

    if (Platform.isAndroid) {
      // Try external storage first
      dir = await getExternalStorageDirectory();
      if (dir != null) {
        final downloadDir = Directory(
          '${dir.parent.parent.parent.parent.path}/Download/${AppConfig.downloadFolderName}',
        );
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    }

    // Fallback to app documents directory
    dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/${AppConfig.downloadFolderName}');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}
