/// Downlo App Settings Entity
/// User preferences stored locally with Hive
class AppSettings {
  final String preferredQuality;
  final bool audioOnly;
  final String downloadPath;
  final bool onboardingCompleted;
  final bool adsRemoved;
  final int totalDownloadCount;
  final DateTime? lastDownloadAt;
  final bool isDarkMode;

  const AppSettings({
    this.preferredQuality = '1080',
    this.audioOnly = false,
    this.downloadPath = '',
    this.onboardingCompleted = false,
    this.adsRemoved = false,
    this.totalDownloadCount = 0,
    this.lastDownloadAt,
    this.isDarkMode = false,
  });

  AppSettings copyWith({
    String? preferredQuality,
    bool? audioOnly,
    String? downloadPath,
    bool? onboardingCompleted,
    bool? adsRemoved,
    int? totalDownloadCount,
    DateTime? lastDownloadAt,
    bool? isDarkMode,
  }) {
    return AppSettings(
      preferredQuality: preferredQuality ?? this.preferredQuality,
      audioOnly: audioOnly ?? this.audioOnly,
      downloadPath: downloadPath ?? this.downloadPath,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      totalDownloadCount: totalDownloadCount ?? this.totalDownloadCount,
      lastDownloadAt: lastDownloadAt ?? this.lastDownloadAt,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  /// Should show interstitial ad after this download?
  bool shouldShowInterstitial(int frequency) {
    if (adsRemoved) return false;
    return totalDownloadCount > 0 && totalDownloadCount % frequency == 0;
  }

  /// Should prompt user to remove ads?
  bool shouldShowRemoveAdsPrompt(int threshold) {
    if (adsRemoved) return false;
    return totalDownloadCount >= threshold;
  }

  /// Available quality options
  static const List<String> qualityOptions = [
    '360',
    '480',
    '720',
    '1080',
    'max',
  ];
}
