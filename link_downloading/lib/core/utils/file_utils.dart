/// Downlo File Utilities
/// Handle file naming, path building, and size formatting
class FileUtils {
  FileUtils._();

  /// Build a file name following the convention:
  /// {platform}_{timestamp}_{quality}.{ext}
  static String buildFileName({
    required String platform,
    required String quality,
    bool isAudioOnly = false,
  }) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final qualityLabel = quality == 'max' ? 'best' : '${quality}p';
    final extension = isAudioOnly ? 'mp3' : 'mp4';

    return '${platform}_${timestamp}_$qualityLabel.$extension';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// Format file size in bytes to human-readable string
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Format download date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Estimate download time remaining
  static String estimateTimeRemaining(double progress, Duration elapsed) {
    if (progress <= 0 || progress >= 1) return '';

    final totalEstimatedMs = elapsed.inMilliseconds / progress;
    final remainingMs = totalEstimatedMs - elapsed.inMilliseconds;
    final remaining = Duration(milliseconds: remainingMs.round());

    if (remaining.inSeconds < 60) return '${remaining.inSeconds}s left';
    if (remaining.inMinutes < 60) return '${remaining.inMinutes} min left';
    return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
  }
}
