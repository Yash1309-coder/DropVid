/// Downlo App Configuration
/// Feature flags and build variant configuration
class AppConfig {
  AppConfig._();

  /// YouTube support flag — controlled via --dart-define=YOUTUBE_ENABLED=true
  /// Play Store build: false (default)
  /// Full APK build: true
  static const bool kYouTubeEnabled = bool.fromEnvironment(
    'YOUTUBE_ENABLED',
    defaultValue: false,
  );

  /// App version
  static const String appVersion = '1.0.0';

  /// Minimum Android SDK
  static const int minSdkVersion = 26;

  /// Max concurrent downloads
  static const int maxConcurrentDownloads = 2;

  /// Interstitial ad frequency — show after every N downloads
  static const int interstitialFrequency = 3;

  /// Remove ads prompt — show after N downloads
  static const int removeAdsPromptAfter = 5;

  /// Splash screen duration
  static const Duration splashDuration = Duration(seconds: 2);

  /// Snackbar auto-dismiss duration
  static const Duration snackbarDuration = Duration(seconds: 3);

  /// Error snackbar duration (longer so user can read)
  static const Duration errorSnackbarDuration = Duration(seconds: 5);

  /// Max auto-retries on download failure
  static const int maxAutoRetries = 2;

  /// Default download folder name
  static const String downloadFolderName = 'Downlo';
}
