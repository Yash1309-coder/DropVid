// Downlo Settings Repository Interface
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  /// Get current settings
  Future<AppSettings> getSettings();

  /// Update settings
  Future<void> updateSettings(AppSettings settings);

  /// Reset to defaults
  Future<void> resetSettings();

  /// Mark onboarding as completed
  Future<void> completeOnboarding();

  /// Mark ads as removed
  Future<void> markAdsRemoved();

  /// Increment download count
  Future<void> incrementDownloadCount();
}
