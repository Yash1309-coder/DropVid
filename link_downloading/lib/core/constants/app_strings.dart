/// Downlo App Strings
/// All user-facing text in one place — no hardcoded strings in widgets
class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────────
  static const String appName = 'Downlo';
  static const String appNameStyled = 'Downlo...';
  static const String appTagline = 'downlo...';

  // ─── Home Screen ───────────────────────────────────
  static const String urlPlaceholder = 'Paste link into the void...';
  static const String downloadButton = 'Download';
  static const String downloading = 'Downloading...';
  static const String invalidUrl = "That doesn't look like a valid link";
  static const String queueIndicator = 'videos in queue';
  static const String videosLabel = 'VIDEOS';

  // ─── Download Complete ─────────────────────────────
  static const String downloadComplete = 'Download Complete!';
  static const String openVideo = 'Open Video';
  static const String share = 'Share';
  static const String history = 'History';

  // ─── Duplicate Dialog ──────────────────────────────
  static const String alreadyDownloaded = 'Already Downloaded';
  static const String alreadyDownloadedBody =
      "You've already downloaded this video. Download again?";
  static const String downloadAgain = 'Download Again';
  static const String cancel = 'Cancel';

  // ─── History Screen ────────────────────────────────
  static const String noDownloadsYet = 'No downloads yet';
  static const String noDownloadsBody =
      'Paste a link on the home screen to get started';
  static const String goToHome = 'Go to Home';
  static const String searchHistory = 'Search downloads...';
  static const String completed = 'Completed';
  static const String failed = 'Failed';
  static const String inProgress = 'In Progress';

  // ─── Delete Dialog ─────────────────────────────────
  static const String deleteDownload = 'Delete Download';
  static const String deleteBody = 'What would you like to remove?';
  static const String recordOnly = 'Record Only';
  static const String fileAndRecord = 'File + Record';

  // ─── Settings Screen ───────────────────────────────
  static const String settings = 'Settings';
  static const String videoQuality = 'Video Quality';
  static const String audioOnly = 'Audio Only';
  static const String audioOnlyDescription = 'Download MP3 instead of video';
  static const String downloadFolder = 'Download Folder';
  static const String clearCache = 'Clear Cache';
  static const String clearCacheTitle = 'Clear Temporary Files?';
  static const String clearCacheBody =
      "Clear temporary files? This won't delete your videos.";
  static const String clear = 'Clear';
  static const String removeAds = 'Remove Ads';
  static const String storageUsage = 'Storage Usage';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // ─── Subscription Screen (Celestial Void) ──────────
  static const String subscriptionBrand = 'Downlo';
  static const String subscriptionHeadline = 'An infinite archive,';
  static const String subscriptionHeadlineItalic = 'without distractions.';
  static const String subscriptionBody =
      'Elevate your collection. Remove all advertisements and support the celestial curator for just';
  static const String subscriptionPrice = '\$2.99/year';
  static const String subscriptionBilling =
      'BILLING WILL BE PROCESSED SECURELY VIA YOUR ITUNES ACCOUNT. SUBSCRIPTION AUTOMATICALLY RENEWS UNLESS CANCELLED 24 HOURS BEFORE THE END OF THE PERIOD.';
  static const String subscribeNow = 'SUBSCRIBE NOW';
  static const String seeTermsOfUse = 'See the Terms of Use';
  static const String seePrivacyPolicy = 'See the Privacy Policy';
  static const String restorePreviousPurchase = 'RESTORE PREVIOUS PURCHASE';
  static const String skip = 'SKIP';

  // ─── Legacy Remove Ads (backward compat) ───────────
  static const String removeAdsTitle = 'Go Ad-Free';
  static const String removeAdsBody =
      'Enjoy Downlo without interruptions. One-time purchase, forever ad-free.';
  static const String removeAdsButton = 'Remove Ads for';
  static const String restorePurchase = 'Restore Purchase';
  static const String purchaseSuccess = 'Ads removed! Thank you ❤️';
  static const String purchaseCancelled = 'Purchase cancelled';
  static const String noPreviousPurchase = 'No previous purchase found';

  // ─── Permissions ───────────────────────────────────
  static const String storagePermissionTitle = 'Storage Permission Required';
  static const String storagePermissionBody =
      'Downlo needs storage access to save videos to your device.';
  static const String openSettings = 'Open Settings';
  static const String notNow = 'Not Now';
  static const String permissionRequired =
      'Permission required to save videos';

  // ─── Errors ────────────────────────────────────────
  static const String noInternet = 'No internet connection.';
  static const String requestTimeout = 'Request timed out. Retry?';
  static const String tooManyRequests =
      'Too many requests. Please wait a moment.';
  static const String serverError = 'Server error. Please try again later.';
  static const String downloadFailed = 'Download failed. Retry?';
  static const String platformNotSupported =
      "This platform isn't supported yet.";
  static const String somethingWentWrong =
      'Something went wrong. Please retry.';
  static const String notEnoughStorage = 'Not enough storage space.';
  static const String retry = 'Retry';

  // ─── Onboarding ────────────────────────────────────
  static const String getStarted = 'Get Started';
  static const String next = 'Next';
  static const String onboard1Title = 'Paste & Download';
  static const String onboard1Body =
      'Copy a video link from any social media app, paste it here, and tap download. That simple.';
  static const String onboard2Title = 'All Platforms Supported';
  static const String onboard2Body =
      'Instagram, TikTok, Twitter, Facebook, Reddit, Pinterest, Snapchat, Vimeo and more.';
  static const String onboard3Title = 'Go Ad-Free';
  static const String onboard3Body =
      'Enjoy Downlo without interruptions with a one-time purchase.';

  // ─── Bottom Nav (3 tabs) ───────────────────────────
  static const String navHome = 'Home';
  static const String navDownloads = 'Downloads';
  static const String navSettings = 'Settings';
  static const String navHistory = 'History';

  // ─── Legal ─────────────────────────────────────────
  static const String copyrightDisclaimer =
      'Only download content you own or have rights to.';
  static const String affiliateDisclaimer =
      'Not affiliated with Instagram, TikTok, or any other platform.';

  // ─── Exit Dialog ───────────────────────────────────
  static const String exitAppTitle = 'Exit Downlo?';
  static const String exitAppBody = 'Are you sure you want to exit?';
  static const String exit = 'Exit';
}
