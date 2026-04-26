/// Downlo Download Item Entity
/// Core domain entity representing a download
enum DownloadStatus {
  queued,
  resolving,    // URL being resolved — "Finding video…"
  fetching,     // Server-side download in progress — "Preparing…"
  merging,      // FFmpeg merge/post-processing — "Almost done…"
  downloading,  // Actual file transfer to device
  completed,
  failed,
  cancelled,
}

class DownloadItem {
  final String id;
  final String url;
  final String platform;
  final String fileName;
  final String filePath;
  final String? thumbnailPath;
  final DownloadStatus status;
  final double progress;
  final int fileSizeBytes;
  final String quality;
  final bool isAudioOnly;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const DownloadItem({
    required this.id,
    required this.url,
    required this.platform,
    required this.fileName,
    required this.filePath,
    this.thumbnailPath,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.fileSizeBytes = 0,
    this.quality = '1080',
    this.isAudioOnly = false,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  /// Create a copy with updated fields
  DownloadItem copyWith({
    String? id,
    String? url,
    String? platform,
    String? fileName,
    String? filePath,
    String? thumbnailPath,
    DownloadStatus? status,
    double? progress,
    int? fileSizeBytes,
    String? quality,
    bool? isAudioOnly,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      quality: quality ?? this.quality,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if file has been downloaded before (duplicate check)
  bool isSameUrl(String otherUrl) {
    return url.trim().toLowerCase() == otherUrl.trim().toLowerCase();
  }

  @override
  String toString() =>
      'DownloadItem($id, $platform, $status, ${(progress * 100).toStringAsFixed(0)}%)';
}
