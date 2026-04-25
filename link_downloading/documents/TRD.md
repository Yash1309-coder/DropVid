📄 File 2 — Save as TRD.md

markdown
# TRD — Technical Requirements Document
## App Name: DropVid
**Version:** 1.0 | **Stack:** Flutter (Android)

---

## 1. Technology Stack

|
 Layer 
|
 Technology 
|
 Reason 
|
|
-------
|
-----------
|
--------
|
|
 Frontend 
|
 Flutter (Dart) 
|
 Cross-platform, single codebase 
|
|
 Backend / Download API 
|
 Cobalt API (cobalt.tools) 
|
 Free, no server needed, supports 1000+ sites 
|
|
 Local Database 
|
 Hive or Isar 
|
 Fast, lightweight, no SQL needed 
|
|
 Ads 
|
 Google AdMob 
|
 Industry standard for Flutter 
|
|
 IAP 
|
 in_app_purchase (Flutter plugin) 
|
 Official Google Play Billing wrapper 
|
|
 Notifications 
|
 flutter_local_notifications 
|
 Background download notifications 
|
|
 Background Tasks 
|
 WorkManager (via flutter_workmanager) 
|
 Keeps downloads alive in background 
|
|
 HTTP Client 
|
 Dio 
|
 Robust HTTP with download progress stream 
|
|
 State Management 
|
 Riverpod 
|
 Clean, scalable, testable 
|
|
 File Storage 
|
 path_provider + permission_handler 
|
 Save to public Downloads folder 
|
|
 Video Thumbnail 
|
 video_thumbnail 
|
 Generate thumbnails for history 
|

---

## 2. Architecture

### 2.1 Architecture Pattern
**Clean Architecture** with 3 layers:
lib/
├── presentation/ # UI — Screens, Widgets, State (Riverpod)
├── domain/ # Business logic — Use Cases, Entities
└── data/ # Repositories, API calls, Local DB

text

### 2.2 Folder Structure
lib/
│
├── main.dart
├── app.dart # MaterialApp, theme, routing
│
├── core/
│ ├── constants/
│ │ ├── app_colors.dart
│ │ ├── app_strings.dart
│ │ └── supported_platforms.dart
│ ├── utils/
│ │ ├── url_validator.dart
│ │ ├── file_utils.dart
│ │ └── connectivity_utils.dart
│ └── errors/
│ └── app_exceptions.dart
│
├── data/
│ ├── api/
│ │ └── cobalt_api_service.dart
│ ├── local/
│ │ ├── hive_service.dart
│ │ └── download_dao.dart
│ └── repositories/
│ └── download_repository_impl.dart
│
├── domain/
│ ├── entities/
│ │ └── download_item.dart
│ ├── repositories/
│ │ └── download_repository.dart
│ └── usecases/
│ ├── start_download.dart
│ ├── get_history.dart
│ ├── delete_history_item.dart
│ └── check_duplicate.dart
│
├── presentation/
│ ├── screens/
│ │ ├── splash/
│ │ │ └── splash_screen.dart
│ │ ├── onboarding/
│ │ │ └── onboarding_screen.dart
│ │ ├── home/
│ │ │ ├── home_screen.dart
│ │ │ └── widgets/
│ │ │ ├── url_input_field.dart
│ │ │ ├── download_button.dart
│ │ │ ├── progress_card.dart
│ │ │ ├── queue_indicator.dart
│ │ │ └── download_complete_sheet.dart
│ │ ├── history/
│ │ │ ├── history_screen.dart
│ │ │ └── widgets/
│ │ │ ├── history_item_card.dart
│ │ │ └── empty_history_view.dart
│ │ ├── settings/
│ │ │ ├── settings_screen.dart
│ │ │ └── widgets/
│ │ │ ├── quality_selector.dart
│ │ │ └── storage_usage_tile.dart
│ │ └── paywall/
│ │ └── remove_ads_screen.dart
│ │
│ ├── providers/
│ │ ├── download_provider.dart
│ │ ├── history_provider.dart
│ │ ├── settings_provider.dart
│ │ └── ads_provider.dart
│ │
│ └── navigation/
│ └── app_router.dart

text

---

## 3. Cobalt API Integration

### 3.1 How Cobalt API Works
Cobalt is a free, open-source video download API. No API key needed for basic use.

**Base URL:** `https://api.cobalt.tools/api/json`

**Request:**
```json
POST /api/json
Content-Type: application/json
Accept: application/json

{
  "url": "https://www.instagram.com/reel/xxxxx/",
  "vQuality": "1080",
  "filenamePattern": "basic",
  "isAudioOnly": false
}
Response (success):

json
{
  "status": "stream",
  "url": "https://cobalt-download-link.com/file.mp4"
}
Response (picker — e.g. Instagram carousel):

json
{
  "status": "picker",
  "picker": [
    { "url": "https://..." },
    { "url": "https://..." }
  ]
}
3.2 Quality Mapping
User Setting	API vQuality Value
360p	"360"
480p	"480"
720p	"720"
1080p	"1080"
Best Available	"max"
3.3 Supported Platforms via Cobalt
Instagram, TikTok, Twitter/X, Reddit, Facebook, Pinterest, Snapchat, Vimeo, Dailymotion, Twitch clips, SoundCloud, Bilibili, and more.

3.4 Error Handling from API
API Status	Meaning	App Action
stream	Direct download URL	Start download
picker	Multiple media items	Show selection bottom sheet
redirect	Redirect to another URL	Follow redirect
error	Platform not supported or rate limited	Show error snackbar
Network timeout	No response in 10s	Show retry option
4. Download Engine
4.1 Download Flow (Step by Step)
text
1.  User pastes URL
2.  URL validated locally (regex check)
3.  Platform detected from URL domain
4.  Duplicate check against local DB
5.  POST request to Cobalt API with URL + quality setting
6.  Receive download URL from Cobalt
7.  Start file download via Dio with progress stream
8.  Save file to /storage/emulated/0/Downloads/DropVid/
9.  Generate thumbnail using video_thumbnail
10. Save record to Hive DB
11. Trigger completion notification
12. Update UI
4.2 Download Queue
Implemented using a simple Dart Queue
Max concurrent downloads: 2 at a time
Additional downloads added to queue and shown in UI
Queue persists if app is backgrounded using WorkManager
4.3 File Naming Convention
text
{platform}_{timestamp}_{quality}.mp4

Example:
instagram_20240815_143022_1080p.mp4
tiktok_20240815_143500_720p.mp4
4.4 Duplicate Detection Logic
dart
// Before starting download:
bool isDuplicate = await downloadRepository.checkUrlExists(url);
if (isDuplicate) {
  // Show dialog to user
}
5. Local Database Schema
5.1 DownloadItem Model (Hive)
dart
@HiveType(typeId: 0)
class DownloadItem extends HiveObject {

  @HiveField(0)
  String id;              // UUID

  @HiveField(1)
  String url;             // Original URL pasted by user

  @HiveField(2)
  String platform;        // "instagram", "tiktok", etc.

  @HiveField(3)
  String filePath;        // Local path to saved file

  @HiveField(4)
  String fileName;        // Display name

  @HiveField(5)
  String? thumbnailPath;  // Local path to thumbnail

  @HiveField(6)
  int fileSizeBytes;      // File size

  @HiveField(7)
  String quality;         // "1080p", "720p", etc.

  @HiveField(8)
  DateTime downloadedAt;  // Timestamp

  @HiveField(9)
  String status;          // "completed", "failed", "in_progress"

  @HiveField(10)
  bool isAudioOnly;       // Was it audio-only download?
}
5.2 Settings Model (SharedPreferences)
text
KEY                     TYPE      DEFAULT
video_quality           String    "1080"
audio_only              bool      false
download_folder         String    "/Downloads/DropVid"
ads_removed             bool      false
onboarding_complete     bool      false
download_count          int       0
6. State Management (Riverpod)
6.1 Key Providers
dart
// Download state
final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>

// Download history list
final historyProvider = FutureProvider<List<DownloadItem>>

// Settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>

// Ads removed status
final adsRemovedProvider = StateProvider<bool>

// Active download queue
final downloadQueueProvider = StateNotifierProvider<QueueNotifier, List<DownloadItem>>
6.2 Download State Machine
text
Idle → Loading (API call) → Downloading (file transfer) → Complete
                                                        → Failed
                          → Cancelled
7. Ads Implementation
7.1 AdMob Setup
Ad Type	Placement	Trigger
Banner (320x50)	Bottom of Home screen	Always visible (free users)
Banner (320x50)	Bottom of History screen	Always visible (free users)
Interstitial	Full screen	After every 3rd completed download
7.2 Interstitial Logic
dart
int downloadCount = prefs.getInt('download_count') ?? 0;
downloadCount++;
prefs.setInt('download_count', downloadCount);

if (downloadCount % 3 == 0 && !adsRemoved) {
  // Show interstitial AFTER download_complete_sheet is dismissed
  interstitialAd.show();
}
7.3 Ad-Free Check
dart
// Wrap every ad widget with this:
if (!ref.watch(adsRemovedProvider)) {
  return BannerAdWidget();
}
return SizedBox.shrink(); // No space taken when ads removed
8. In-App Purchase (Remove Ads)
8.1 Product Setup
Field	Value
Product Type	One-time purchase (non-consumable)
Product ID	remove_ads_lifetime
Plugin	in_app_purchase
8.2 Purchase Flow
text
Tap "Remove Ads"
→ Query product details from Play Store
→ Show price to user
→ Initiate purchase
→ Verify purchase
→ Save ads_removed = true to SharedPreferences
→ Dismiss all ad widgets
8.3 Restore Purchase
On app launch, call restorePurchases() to handle reinstalls
If remove_ads_lifetime found in purchase history → set ads_removed = true
9. Permissions
Permission	When Requested	Why
WRITE_EXTERNAL_STORAGE	Before first download	Save video to Downloads folder
READ_EXTERNAL_STORAGE	Before first download	Read saved files in History
POST_NOTIFICATIONS	On first download	Show download progress notification
INTERNET	Auto (manifest)	API calls and downloads
Note: For Android 13+ (API 33+), use READ_MEDIA_VIDEO instead of READ_EXTERNAL_STORAGE

10. Notifications
10.1 Notification Types
Type	Title	Body
Progress	"Downloading..."	"instagram_video.mp4 — 45%"
Complete	"Download Complete ✓"	"instagram_video.mp4 saved to Downloads"
Failed	"Download Failed"	"Tap to retry"
10.2 Notification Channel
text
Channel ID:   dropvid_downloads
Channel Name: Downloads
Importance:   HIGH (shows heads-up for completion)
11. Error Handling Strategy
Error Type	Detection	User-Facing Response
Invalid URL	Local regex	"That doesn't look like a valid link"
Unsupported platform	Cobalt API error response	"This platform isn't supported yet"
No internet	Connectivity check	"No internet connection"
API timeout (>10s)	Dio timeout	"Taking too long. Retry?"
API rate limit	HTTP 429 response	"Too many requests. Try again in a moment"
Insufficient storage	File write exception	"Not enough storage space"
Download corrupted	File size validation	"Download failed. File may be corrupted. Retry?"
12. Android Manifest Requirements
xml
<!-- Permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>

<!-- For background downloads -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
13. Dependencies (pubspec.yaml)
yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^12.0.0

  # Networking
  dio: ^5.3.0
  connectivity_plus: ^5.0.0

  # Local Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0

  # File & Storage
  path_provider: ^2.1.0
  permission_handler: ^11.0.0
  open_filex: ^4.3.0

  # Video
  video_thumbnail: ^0.5.3
  video_player: ^2.7.0

  # Notifications
  flutter_local_notifications: ^16.0.0
  workmanager: ^0.5.2

  # Ads
  google_mobile_ads: ^4.0.0

  # IAP
  in_app_purchase: ^3.1.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0

  # Utils
  uuid: ^4.2.0
  intl: ^0.18.0
  url_launcher: ^6.2.0

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0
14. Build Variants
Variant	YouTube Support	Ads	Distribution
release-playstore	No	Yes	Google Play Store
release-full	Yes	Yes	Direct APK (website)
Feature flag:

dart
// core/constants/app_config.dart
const bool kYouTubeEnabled = bool.fromEnvironment(
  'YOUTUBE_ENABLED',
  defaultValue: false,
);
Build commands:

bash
# Play Store build
flutter build apk --release

# Full APK build (with YouTube)
flutter build apk --release --dart-define=YOUTUBE_ENABLED=true
15. Minimum Device Requirements
Spec	Minimum
Android Version	8.0 (API 26)
RAM	2GB
Storage	50MB for app + space for downloads
Internet	Required for downloading