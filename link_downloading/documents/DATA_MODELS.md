## App: DropVid
**Version:** 1.0

---

## 1. DownloadItem (Primary Model)

### 1.1 Entity (Domain Layer)
```dart
// lib/domain/entities/download_item.dart

class DownloadItem {
  final String   id;             // UUID v4 — unique per download
  final String   url;            // Original URL pasted by user
  final String   platform;       // "instagram" | "tiktok" | "twitter" | "facebook" | "reddit" | "pinterest" | "snapchat" | "vimeo" | "dailymotion" | "unknown"
  final String   filePath;       // Absolute path to saved file on device
  final String   fileName;       // Human-readable file name (e.g. "instagram_20240815_1080p.mp4")
  final String?  thumbnailPath;  // Absolute path to thumbnail image (nullable — may fail to generate)
  final int      fileSizeBytes;  // File size in bytes (0 if unknown)
  final String   quality;        // "360p" | "480p" | "720p" | "1080p" | "max" | "audio"
  final DateTime downloadedAt;   // UTC timestamp of when download completed
  final DownloadStatus status;   // See enum below
  final bool     isAudioOnly;    // true = MP3, false = video file
  final String?  errorMessage;   // Only set when status == failed

  const DownloadItem({
    required this.id,
    required this.url,
    required this.platform,
    required this.filePath,
    required this.fileName,
    this.thumbnailPath,
    required this.fileSizeBytes,
    required this.quality,
    required this.downloadedAt,
    required this.status,
    required this.isAudioOnly,
    this.errorMessage,
  });
}
1.2 Status Enum
dart
// lib/domain/entities/download_status.dart

enum DownloadStatus {
  inProgress,   // Actively downloading
  completed,    // Successfully saved to device
  failed,       // Download failed (see errorMessage)
  cancelled,    // Cancelled by user
  queued,       // Waiting in queue
}
1.3 Hive Model (Data Layer)
dart
// lib/data/local/models/download_item_hive.dart

@HiveType(typeId: 0)
class DownloadItemHive extends HiveObject {
  @HiveField(0)  String   id;
  @HiveField(1)  String   url;
  @HiveField(2)  String   platform;
  @HiveField(3)  String   filePath;
  @HiveField(4)  String   fileName;
  @HiveField(5)  String?  thumbnailPath;
  @HiveField(6)  int      fileSizeBytes;
  @HiveField(7)  String   quality;
  @HiveField(8)  DateTime downloadedAt;
  @HiveField(9)  String   status;          // Stored as string, mapped to enum
  @HiveField(10) bool     isAudioOnly;
  @HiveField(11) String?  errorMessage;
}
1.4 Mapper (Hive ↔ Entity)
dart
// lib/data/local/mappers/download_item_mapper.dart

extension DownloadItemMapper on DownloadItemHive {
  DownloadItem toEntity() => DownloadItem(
    id:            id,
    url:           url,
    platform:      platform,
    filePath:      filePath,
    fileName:      fileName,
    thumbnailPath: thumbnailPath,
    fileSizeBytes: fileSizeBytes,
    quality:       quality,
    downloadedAt:  downloadedAt,
    status:        DownloadStatus.values.byName(status),
    isAudioOnly:   isAudioOnly,
    errorMessage:  errorMessage,
  );
}

extension DownloadItemEntityMapper on DownloadItem {
  DownloadItemHive toHive() => DownloadItemHive()
    ..id            = id
    ..url           = url
    ..platform      = platform
    ..filePath      = filePath
    ..fileName      = fileName
    ..thumbnailPath = thumbnailPath
    ..fileSizeBytes = fileSizeBytes
    ..quality       = quality
    ..downloadedAt  = downloadedAt
    ..status        = status.name
    ..isAudioOnly   = isAudioOnly
    ..errorMessage  = errorMessage;
}
2. DownloadState (UI State Model)
dart
// lib/presentation/providers/download_provider.dart

enum DownloadPhase {
  idle,           // Nothing happening
  validating,     // Checking URL format + duplicate
  fetchingUrl,    // Calling Cobalt API
  downloading,    // File transfer in progress
  completed,      // Done
  failed,         // Error occurred
}

class DownloadState {
  final DownloadPhase phase;
  final double        progress;        // 0.0 to 1.0
  final String?       fileName;        // Current file being downloaded
  final String?       platform;        // Detected platform
  final String?       timeRemaining;   // e.g. "2 min left"
  final String?       errorMessage;    // User-facing error
  final DownloadItem? completedItem;   // Set when phase == completed

  const DownloadState({
    this.phase          = DownloadPhase.idle,
    this.progress       = 0.0,
    this.fileName,
    this.platform,
    this.timeRemaining,
    this.errorMessage,
    this.completedItem,
  });

  DownloadState copyWith({
    DownloadPhase? phase,
    double?        progress,
    String?        fileName,
    String?        platform,
    String?        timeRemaining,
    String?        errorMessage,
    DownloadItem?  completedItem,
  }) { ... }
}
3. QueueItem Model
dart
// lib/domain/entities/queue_item.dart

class QueueItem {
  final String   id;         // UUID
  final String   url;        // URL to download
  final String   quality;    // Quality at time of queuing
  final bool     isAudioOnly;
  final DateTime queuedAt;

  const QueueItem({
    required this.id,
    required this.url,
    required this.quality,
    required this.isAudioOnly,
    required this.queuedAt,
  });
}
4. Settings Model
dart
// lib/domain/entities/app_settings.dart

class AppSettings {
  final String  videoQuality;      // "360" | "480" | "720" | "1080" | "max"
  final bool    isAudioOnly;       // Global audio-only mode
  final String  downloadFolder;    // Absolute path to download directory
  final bool    adsRemoved;        // IAP status
  final bool    onboardingDone;    // First launch flag
  final int     downloadCount;     // Total downloads (for interstitial trigger)

  const AppSettings({
    this.videoQuality  = '1080',
    this.isAudioOnly   = false,
    this.downloadFolder = '/storage/emulated/0/Downloads/DropVid',
    this.adsRemoved    = false,
    this.onboardingDone = false,
    this.downloadCount  = 0,
  });

  AppSettings copyWith({ ... });
}
SharedPreferences key map:

text
Key                      Type     Default
─────────────────────────────────────────
video_quality            String   "1080"
is_audio_only            bool     false
download_folder          String   "/storage/emulated/0/Downloads/DropVid"
ads_removed              bool     false
onboarding_done          bool     false
download_count           int      0
5. CobaltResponse Model
dart
// lib/data/api/models/cobalt_response.dart

class CobaltResponse {
  final String            status;    // "stream" | "redirect" | "picker" | "error"
  final String?           url;       // Set when status == stream | redirect
  final String?           text;      // Set when status == error
  final String?           audio;     // Set when status == picker (optional bg audio)
  final List<PickerItem>? picker;    // Set when status == picker

  const CobaltResponse({
    required this.status,
    this.url,
    this.text,
    this.audio,
    this.picker,
  });

  factory CobaltResponse.fromJson(Map<String, dynamic> json) => CobaltResponse(
    status: json['status'] as String,
    url:    json['url']    as String?,
    text:   json['text']   as String?,
    audio:  json['audio']  as String?,
    picker: (json['picker'] as List<dynamic>?)
                ?.map((e) => PickerItem.fromJson(e))
                .toList(),
  );
}

class PickerItem {
  final String  type;    // "photo" | "video"
  final String  url;     // Download URL
  final String? thumb;   // Thumbnail URL

  const PickerItem({
    required this.type,
    required this.url,
    this.thumb,
  });

  factory PickerItem.fromJson(Map<String, dynamic> json) => PickerItem(
    type:  json['type']  as String,
    url:   json['url']   as String,
    thumb: json['thumb'] as String?,
  );
}
6. Model Relationships
text
AppSettings (SharedPreferences)
  └── Read by: SettingsNotifier, DownloadNotifier, AdsProvider

DownloadItem (Hive Box)
  └── Created by: DownloadRepository
  └── Read by:    HistoryScreen, HistoryProvider
  └── Deleted by: HistoryScreen user action

DownloadState (In-memory Riverpod)
  └── Managed by: DownloadNotifier
  └── Consumed by: HomeScreen, ProgressCard

QueueItem (In-memory List)
  └── Managed by: QueueNotifier
  └── Consumed by: QueueIndicator, DownloadNotifier

CobaltResponse (Transient)
  └── Created by: CobaltApiService
  └── Consumed by: DownloadRepository
  └── Never persisted to DB
7. Null Safety Rules
Field	Nullable?	Reason
thumbnailPath	Yes	Thumbnail generation can fail silently
errorMessage	Yes	Only present on failed downloads
PickerItem.thumb	Yes	Not all picker items have thumbnails
CobaltResponse.url	Yes	Not present in picker/error responses
DownloadState.completedItem	Yes	Only set when phase == completed
All other fields	No	Required for app to function
