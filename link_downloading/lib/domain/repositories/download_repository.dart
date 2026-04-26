// Downlo Download Repository Interface
// Domain layer contract — implemented by data layer
import '../entities/download_item.dart';

abstract class DownloadRepository {
  /// Get all downloads (sorted by date, newest first)
  Future<List<DownloadItem>> getAllDownloads();

  /// Get downloads filtered by status
  Future<List<DownloadItem>> getDownloadsByStatus(DownloadStatus status);

  /// Get a single download by ID
  Future<DownloadItem?> getDownloadById(String id);

  /// Check if URL has been downloaded before
  Future<DownloadItem?> findByUrl(String url);

  /// Save a new download record
  Future<void> saveDownload(DownloadItem item);

  /// Update an existing download record
  Future<void> updateDownload(DownloadItem item);

  /// Delete a download record (optionally delete file too)
  Future<void> deleteDownload(String id, {bool deleteFile = false});

  /// Delete all download records
  Future<void> clearAllDownloads({bool deleteFiles = false});

  /// Search downloads by filename
  Future<List<DownloadItem>> searchDownloads(String query);

  /// Get total storage used in bytes
  Future<int> getTotalStorageUsed();
}
