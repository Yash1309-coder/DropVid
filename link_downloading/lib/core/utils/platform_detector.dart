import '../constants/supported_platforms.dart';
import '../constants/app_config.dart';

/// Downlo Platform Detector
/// Detects which social media platform a URL belongs to
class PlatformDetector {
  PlatformDetector._();

  /// Detect platform from URL
  /// Returns platform name string like "instagram", "tiktok", etc.
  /// Returns "unknown" if platform cannot be detected
  static String detect(String url) {
    try {
      final uri = Uri.parse(url.trim());
      final host = uri.host.toLowerCase();

      // Check standard platforms
      for (final entry in SupportedPlatforms.domainMap.entries) {
        if (host == entry.key || host.endsWith('.${entry.key}')) {
          return entry.value;
        }
      }

      // Check YouTube domains (only if enabled)
      if (AppConfig.kYouTubeEnabled) {
        for (final entry in SupportedPlatforms.youtubeDomains.entries) {
          if (host == entry.key || host.endsWith('.${entry.key}')) {
            return entry.value;
          }
        }
      }

      return 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  /// Check if the detected platform is YouTube
  static bool isYouTube(String url) {
    return detect(url) == 'youtube';
  }

  /// Get display name for a platform
  static String getDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'Instagram';
      case 'tiktok':
        return 'TikTok';
      case 'twitter':
        return 'Twitter/X';
      case 'facebook':
        return 'Facebook';
      case 'reddit':
        return 'Reddit';
      case 'pinterest':
        return 'Pinterest';
      case 'snapchat':
        return 'Snapchat';
      case 'vimeo':
        return 'Vimeo';
      case 'dailymotion':
        return 'Dailymotion';
      case 'youtube':
        return 'YouTube';
      default:
        return 'Unknown';
    }
  }
}
