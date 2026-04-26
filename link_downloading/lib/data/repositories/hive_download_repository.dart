import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../models/hive_download_item.dart';

/// Hive implementation of DownloadRepository
class HiveDownloadRepository implements DownloadRepository {
  static const String boxName = 'downloads';
  late Box<HiveDownloadItem> _box;

  HiveDownloadRepository();

  Future<void> init() async {
    _box = await Hive.openBox<HiveDownloadItem>(boxName);
  }

  @override
  Future<List<DownloadItem>> getAllDownloads() async {
    final items = _box.values.map((e) => e.toEntity()).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<List<DownloadItem>> getDownloadsByStatus(DownloadStatus status) async {
    return _box.values
        .where((e) => e.statusIndex == status.index)
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<DownloadItem?> getDownloadById(String id) async {
    try {
      return _box.values.firstWhere((e) => e.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DownloadItem?> findByUrl(String url) async {
    try {
      final normalizedUrl = url.trim().toLowerCase();
      return _box.values
          .firstWhere((e) => e.url.trim().toLowerCase() == normalizedUrl)
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDownload(DownloadItem item) async {
    await _box.put(item.id, HiveDownloadItem.fromEntity(item));
  }

  @override
  Future<void> updateDownload(DownloadItem item) async {
    await _box.put(item.id, HiveDownloadItem.fromEntity(item));
  }

  @override
  Future<void> deleteDownload(String id, {bool deleteFile = false}) async {
    if (deleteFile) {
      final item = await getDownloadById(id);
      if (item != null && item.filePath.isNotEmpty) {
        final file = File(item.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await _box.delete(id);
  }

  @override
  Future<void> clearAllDownloads({bool deleteFiles = false}) async {
    if (deleteFiles) {
      for (final item in _box.values) {
        final file = File(item.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await _box.clear();
  }

  @override
  Future<List<DownloadItem>> searchDownloads(String query) async {
    final q = query.toLowerCase();
    return _box.values
        .where((e) =>
            e.fileName.toLowerCase().contains(q) ||
            e.platform.toLowerCase().contains(q))
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<int> getTotalStorageUsed() async {
    int total = 0;
    for (final item in _box.values) {
      total += item.fileSizeBytes;
    }
    return total;
  }
}
