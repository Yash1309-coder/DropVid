import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/hive_app_settings.dart';

/// Hive implementation of SettingsRepository
class HiveSettingsRepository implements SettingsRepository {
  static const String boxName = 'settings';
  static const String settingsKey = 'app_settings';
  late Box<HiveAppSettings> _box;

  HiveSettingsRepository();

  Future<void> init() async {
    _box = await Hive.openBox<HiveAppSettings>(boxName);
  }

  @override
  Future<AppSettings> getSettings() async {
    final hiveSettings = _box.get(settingsKey);
    if (hiveSettings == null) {
      return const AppSettings();
    }
    return hiveSettings.toEntity();
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _box.put(settingsKey, HiveAppSettings.fromEntity(settings));
  }

  @override
  Future<void> resetSettings() async {
    await _box.put(settingsKey, HiveAppSettings.fromEntity(const AppSettings()));
  }

  @override
  Future<void> completeOnboarding() async {
    final current = await getSettings();
    await updateSettings(current.copyWith(onboardingCompleted: true));
  }

  @override
  Future<void> markAdsRemoved() async {
    final current = await getSettings();
    await updateSettings(current.copyWith(adsRemoved: true));
  }

  @override
  Future<void> incrementDownloadCount() async {
    final current = await getSettings();
    await updateSettings(current.copyWith(
      totalDownloadCount: current.totalDownloadCount + 1,
      lastDownloadAt: DateTime.now(),
    ));
  }
}
