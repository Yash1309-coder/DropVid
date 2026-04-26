import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/app_settings.dart';

/// Hive adapter for AppSettings
/// TypeId: 1
class HiveAppSettings extends HiveObject {
  @HiveField(0)
  late String preferredQuality;

  @HiveField(1)
  late bool audioOnly;

  @HiveField(2)
  late String downloadPath;

  @HiveField(3)
  late bool onboardingCompleted;

  @HiveField(4)
  late bool adsRemoved;

  @HiveField(5)
  late int totalDownloadCount;

  @HiveField(6)
  DateTime? lastDownloadAt;

  @HiveField(7)
  late bool isDarkMode;

  HiveAppSettings();

  factory HiveAppSettings.fromEntity(AppSettings entity) {
    return HiveAppSettings()
      ..preferredQuality = entity.preferredQuality
      ..audioOnly = entity.audioOnly
      ..downloadPath = entity.downloadPath
      ..onboardingCompleted = entity.onboardingCompleted
      ..adsRemoved = entity.adsRemoved
      ..totalDownloadCount = entity.totalDownloadCount
      ..lastDownloadAt = entity.lastDownloadAt
      ..isDarkMode = entity.isDarkMode;
  }

  AppSettings toEntity() {
    return AppSettings(
      preferredQuality: preferredQuality,
      audioOnly: audioOnly,
      downloadPath: downloadPath,
      onboardingCompleted: onboardingCompleted,
      adsRemoved: adsRemoved,
      totalDownloadCount: totalDownloadCount,
      lastDownloadAt: lastDownloadAt,
      isDarkMode: isDarkMode,
    );
  }
}

class HiveAppSettingsAdapter extends TypeAdapter<HiveAppSettings> {
  @override
  final int typeId = 1;

  @override
  HiveAppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAppSettings()
      ..preferredQuality = fields[0] as String
      ..audioOnly = fields[1] as bool
      ..downloadPath = fields[2] as String
      ..onboardingCompleted = fields[3] as bool
      ..adsRemoved = fields[4] as bool
      ..totalDownloadCount = fields[5] as int
      ..lastDownloadAt = fields[6] as DateTime?
      ..isDarkMode = (fields[7] as bool?) ?? true;
  }

  @override
  void write(BinaryWriter writer, HiveAppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.preferredQuality)
      ..writeByte(1)
      ..write(obj.audioOnly)
      ..writeByte(2)
      ..write(obj.downloadPath)
      ..writeByte(3)
      ..write(obj.onboardingCompleted)
      ..writeByte(4)
      ..write(obj.adsRemoved)
      ..writeByte(5)
      ..write(obj.totalDownloadCount)
      ..writeByte(6)
      ..write(obj.lastDownloadAt)
      ..writeByte(7)
      ..write(obj.isDarkMode);
  }
}
