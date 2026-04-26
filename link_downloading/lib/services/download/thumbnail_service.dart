import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Generates and caches video thumbnails from downloaded files.
class ThumbnailService {
  static const _thumbDir = 'thumbnails';

  /// Generate a thumbnail for a video file and return its saved path.
  /// Returns null if thumbnail generation fails (e.g. audio-only file).
  static Future<String?> generateThumbnail({
    required String videoPath,
    required String itemId,
  }) async {
    try {
      final file = File(videoPath);
      if (!await file.exists()) {
        debugPrint('[Thumbnail] Video file not found: $videoPath');
        return null;
      }

      // Get thumbnail storage directory
      final appDir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory('${appDir.path}/$_thumbDir');
      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      final thumbPath = '${thumbDir.path}/$itemId.jpg';

      // Skip if thumbnail already exists
      if (await File(thumbPath).exists()) {
        debugPrint('[Thumbnail] Already exists: $thumbPath');
        return thumbPath;
      }

      debugPrint('[Thumbnail] Generating from: $videoPath');

      // Strategy 1: Generate as bytes and write to our target path directly
      // This avoids cross-filesystem rename issues
      final Uint8List? thumbData = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      if (thumbData == null || thumbData.isEmpty) {
        debugPrint('[Thumbnail] thumbnailData returned null/empty');
        return null;
      }

      // Write bytes directly to our target path
      await File(thumbPath).writeAsBytes(thumbData);
      debugPrint('[Thumbnail] Saved ${thumbData.length} bytes to: $thumbPath');
      return thumbPath;
    } catch (e) {
      debugPrint('[Thumbnail] Error generating thumbnail: $e');
      return null;
    }
  }

  /// Delete a thumbnail file for a given item ID.
  static Future<void> deleteThumbnail(String itemId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbFile = File('${appDir.path}/$_thumbDir/$itemId.jpg');
      if (await thumbFile.exists()) {
        await thumbFile.delete();
      }
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}
