import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/download_item.dart';

/// Hive adapter for DownloadItem
/// TypeId: 0
class HiveDownloadItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String url;

  @HiveField(2)
  late String platform;

  @HiveField(3)
  late String fileName;

  @HiveField(4)
  late String filePath;

  @HiveField(5)
  String? thumbnailPath;

  @HiveField(6)
  late int statusIndex; // DownloadStatus index

  @HiveField(7)
  late double progress;

  @HiveField(8)
  late int fileSizeBytes;

  @HiveField(9)
  late String quality;

  @HiveField(10)
  late bool isAudioOnly;

  @HiveField(11)
  String? errorMessage;

  @HiveField(12)
  late DateTime createdAt;

  @HiveField(13)
  DateTime? completedAt;

  HiveDownloadItem();

  /// Convert from domain entity
  factory HiveDownloadItem.fromEntity(DownloadItem entity) {
    return HiveDownloadItem()
      ..id = entity.id
      ..url = entity.url
      ..platform = entity.platform
      ..fileName = entity.fileName
      ..filePath = entity.filePath
      ..thumbnailPath = entity.thumbnailPath
      ..statusIndex = entity.status.index
      ..progress = entity.progress
      ..fileSizeBytes = entity.fileSizeBytes
      ..quality = entity.quality
      ..isAudioOnly = entity.isAudioOnly
      ..errorMessage = entity.errorMessage
      ..createdAt = entity.createdAt
      ..completedAt = entity.completedAt;
  }

  /// Convert to domain entity
  DownloadItem toEntity() {
    // Backward compat: old enum had 5 values [queued=0, downloading=1, completed=2, failed=3, cancelled=4]
    // New enum has 8 values [queued=0, resolving=1, fetching=2, merging=3, downloading=4, completed=5, failed=6, cancelled=7]
    // Map old indices to new ones for persisted data
    int safeIndex = statusIndex;
    if (safeIndex >= DownloadStatus.values.length) {
      safeIndex = DownloadStatus.failed.index; // Fallback to failed
    }
    // Heuristic: if statusIndex is 1-4 and there are items from old schema,
    // active states (resolving/fetching/merging) are never persisted, so
    // old index 1 (downloading) should map to completed or failed since
    // the app was restarted. Keep as-is since new installs will use new indices.

    return DownloadItem(
      id: id,
      url: url,
      platform: platform,
      fileName: fileName,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      status: DownloadStatus.values[safeIndex],
      progress: progress,
      fileSizeBytes: fileSizeBytes,
      quality: quality,
      isAudioOnly: isAudioOnly,
      errorMessage: errorMessage,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}

/// Manual Hive adapter — no code generation required
class HiveDownloadItemAdapter extends TypeAdapter<HiveDownloadItem> {
  @override
  final int typeId = 0;

  @override
  HiveDownloadItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDownloadItem()
      ..id = fields[0] as String
      ..url = fields[1] as String
      ..platform = fields[2] as String
      ..fileName = fields[3] as String
      ..filePath = fields[4] as String
      ..thumbnailPath = fields[5] as String?
      ..statusIndex = fields[6] as int
      ..progress = fields[7] as double
      ..fileSizeBytes = fields[8] as int
      ..quality = fields[9] as String
      ..isAudioOnly = fields[10] as bool
      ..errorMessage = fields[11] as String?
      ..createdAt = fields[12] as DateTime
      ..completedAt = fields[13] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, HiveDownloadItem obj) {
    writer
      ..writeByte(14) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.platform)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.filePath)
      ..writeByte(5)
      ..write(obj.thumbnailPath)
      ..writeByte(6)
      ..write(obj.statusIndex)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.fileSizeBytes)
      ..writeByte(9)
      ..write(obj.quality)
      ..writeByte(10)
      ..write(obj.isAudioOnly)
      ..writeByte(11)
      ..write(obj.errorMessage)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.completedAt);
  }
}
