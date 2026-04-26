import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/entities/app_settings.dart';
import '../../data/repositories/hive_download_repository.dart';
import '../../data/repositories/hive_settings_repository.dart';
import '../../data/datasources/remote/cobalt_api_service.dart';
import '../../data/datasources/remote/ytdlp_api_service.dart';
import '../../services/download/download_service.dart';
import '../../services/download/foreground_download_service.dart';
import '../../services/download/thumbnail_service.dart';
import '../../core/utils/url_validator.dart';
import '../../core/utils/platform_detector.dart';
import '../../core/utils/file_utils.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_config.dart';

// ─── Service Providers ───────────────────────────────
final cobaltApiProvider = Provider<CobaltApiService>((ref) {
  return CobaltApiService();
});

final ytdlpApiProvider = Provider<YtDlpApiService>((ref) {
  return YtDlpApiService(baseUrl: ApiConstants.ytdlpBackendUrl);
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final downloadRepoProvider = Provider<HiveDownloadRepository>((ref) {
  return HiveDownloadRepository();
});

final settingsRepoProvider = Provider<HiveSettingsRepository>((ref) {
  return HiveSettingsRepository();
});

// ─── Settings Provider ───────────────────────────────
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepoProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final HiveSettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const AppSettings());

  Future<void> load() async {
    state = await _repo.getSettings();
  }

  Future<void> setQuality(String quality) async {
    state = state.copyWith(preferredQuality: quality);
    await _repo.updateSettings(state);
  }

  Future<void> toggleAudioOnly() async {
    state = state.copyWith(audioOnly: !state.audioOnly);
    await _repo.updateSettings(state);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await _repo.completeOnboarding();
  }

  Future<void> markAdsRemoved() async {
    state = state.copyWith(adsRemoved: true);
    await _repo.markAdsRemoved();
  }

  Future<void> incrementDownloadCount() async {
    state = state.copyWith(
      totalDownloadCount: state.totalDownloadCount + 1,
      lastDownloadAt: DateTime.now(),
    );
    await _repo.incrementDownloadCount();
  }

  Future<void> setDarkMode(bool isDark) async {
    state = state.copyWith(isDarkMode: isDark);
    await _repo.updateSettings(state);
  }
}

// ─── Downloads List Provider ─────────────────────────
final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, List<DownloadItem>>((ref) {
  return DownloadsNotifier(ref.read(downloadRepoProvider));
});

class DownloadsNotifier extends StateNotifier<List<DownloadItem>> {
  final HiveDownloadRepository _repo;

  DownloadsNotifier(this._repo) : super([]);

  Future<void> load() async {
    state = await _repo.getAllDownloads();
  }

  void updateItem(DownloadItem item) {
    state = [
      for (final d in state)
        if (d.id == item.id) item else d,
    ];
  }

  void addItem(DownloadItem item) {
    state = [item, ...state];
  }

  Future<void> removeItem(String id, {bool deleteFile = false}) async {
    await _repo.deleteDownload(id, deleteFile: deleteFile);
    state = state.where((d) => d.id != id).toList();
  }

  Future<void> clearAll({bool deleteFiles = false}) async {
    await _repo.clearAllDownloads(deleteFiles: deleteFiles);
    state = [];
  }
}

// ─── Active Download State ───────────────────────────
class ActiveDownloadState {
  final bool isDownloading;
  final DownloadItem? currentItem;
  final String? errorMessage;

  const ActiveDownloadState({
    this.isDownloading = false,
    this.currentItem,
    this.errorMessage,
  });

  ActiveDownloadState copyWith({
    bool? isDownloading,
    DownloadItem? currentItem,
    String? errorMessage,
  }) {
    return ActiveDownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      currentItem: currentItem ?? this.currentItem,
      errorMessage: errorMessage,
    );
  }
}

final activeDownloadProvider =
    StateNotifierProvider<ActiveDownloadNotifier, ActiveDownloadState>((ref) {
  return ActiveDownloadNotifier(ref);
});

class ActiveDownloadNotifier extends StateNotifier<ActiveDownloadState> {
  final Ref _ref;
  CancelToken? _cancelToken;

  ActiveDownloadNotifier(this._ref) : super(const ActiveDownloadState());

  /// Start a download from URL
  Future<void> startDownload(String url, {String? qualityOverride, bool? audioOnlyOverride}) async {
    if (state.isDownloading) return;

    // Validate URL
    if (!UrlValidator.isValidUrl(url)) {
      state = const ActiveDownloadState(
        errorMessage: "That doesn't look like a valid link",
      );
      return;
    }

    final platform = PlatformDetector.detect(url);
    if (platform == 'unknown') {
      state = const ActiveDownloadState(
        errorMessage: "This platform isn't supported yet",
      );
      return;
    }

    // Check for duplicates (reserved for future use)
    final repo = _ref.read(downloadRepoProvider);

    final settings = _ref.read(settingsProvider);
    final quality = qualityOverride ?? settings.preferredQuality;
    final isAudioOnly = audioOnlyOverride ?? settings.audioOnly;

    // Create download item
    final id = const Uuid().v4();
    final fileName = FileUtils.buildFileName(
      platform: platform,
      quality: quality,
      isAudioOnly: isAudioOnly,
    );

    var item = DownloadItem(
      id: id,
      url: url,
      platform: platform,
      fileName: fileName,
      filePath: '',
      status: DownloadStatus.downloading,
      quality: quality,
      isAudioOnly: isAudioOnly,
      createdAt: DateTime.now(),
    );

    state = ActiveDownloadState(isDownloading: true, currentItem: item);
    _ref.read(downloadsProvider.notifier).addItem(item);

    // Start foreground service so download survives background
    await ForegroundDownloadService.startService(title: 'Finding video on $platform...');

    try {
      // Step 1: Resolve URL — route YouTube to self-hosted backend, others to Cobalt
      // Set resolving status so UI shows "Finding video…" instead of 0%
      item = item.copyWith(status: DownloadStatus.resolving);
      state = ActiveDownloadState(isDownloading: true, currentItem: item);
      _ref.read(downloadsProvider.notifier).updateItem(item);

      final isYouTube = AppConfig.kYouTubeEnabled && PlatformDetector.isYouTube(url);
      final dynamic apiService;
      if (isYouTube) {
        apiService = _ref.read(ytdlpApiProvider);
      } else {
        apiService = _ref.read(cobaltApiProvider);
      }

      final response = await apiService.resolveUrl(
        url: url,
        quality: quality,
        isAudioOnly: isAudioOnly,
        onProgress: (String status, double progress, String? title) {
          // Map backend status strings to our DownloadStatus enum
          final DownloadStatus uiStatus;
          final String notifTitle;
          switch (status) {
            case 'extracting':
              uiStatus = DownloadStatus.resolving;
              notifTitle = title ?? 'Fetching video info...';
            case 'downloading':
              uiStatus = DownloadStatus.fetching;
              notifTitle = title ?? 'Server downloading...';
            case 'merging':
              uiStatus = DownloadStatus.merging;
              notifTitle = title ?? 'Merging streams...';
            default:
              uiStatus = DownloadStatus.resolving;
              notifTitle = 'Preparing download...';
          }
          item = item.copyWith(
            status: uiStatus,
            progress: progress / 100, // Backend sends 0-100, we use 0.0-1.0
          );
          state = ActiveDownloadState(isDownloading: true, currentItem: item);
          _ref.read(downloadsProvider.notifier).updateItem(item);
          ForegroundDownloadService.updateProgress(
            title: notifTitle,
            progress: progress / 100,
          );
        },
      );

      if (response.isError) {
        item = item.copyWith(
          status: DownloadStatus.failed,
          errorMessage: response.error ?? 'Failed to resolve URL',
        );
        await repo.saveDownload(item);
        _ref.read(downloadsProvider.notifier).updateItem(item);
        state = ActiveDownloadState(errorMessage: response.error);
        return;
      }

      final downloadUrl = response.downloadUrl;
      if (downloadUrl == null || downloadUrl.isEmpty) {
        item = item.copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'No download URL found',
        );
        await repo.saveDownload(item);
        _ref.read(downloadsProvider.notifier).updateItem(item);
        state = const ActiveDownloadState(errorMessage: 'No download URL found');
        return;
      }

      // Step 2: Download the file to device
      // Transition to 'downloading' — actual file transfer begins
      item = item.copyWith(status: DownloadStatus.downloading, progress: 0);
      state = ActiveDownloadState(isDownloading: true, currentItem: item);
      _ref.read(downloadsProvider.notifier).updateItem(item);
      ForegroundDownloadService.updateProgress(
        title: 'Downloading from $platform',
        progress: 0,
      );

      _cancelToken = CancelToken();
      final downloadService = _ref.read(downloadServiceProvider);

      final filePath = await downloadService.downloadFile(
        downloadUrl: downloadUrl,
        fileName: fileName,
        cancelToken: _cancelToken,
        onProgress: (progress) {
          item = item.copyWith(progress: progress);
          state = ActiveDownloadState(isDownloading: true, currentItem: item);
          _ref.read(downloadsProvider.notifier).updateItem(item);
          // Update the foreground notification with progress
          ForegroundDownloadService.updateProgress(
            title: 'Downloading from $platform',
            progress: progress,
          );
        },
      );

      // Step 3: Get file size and mark complete
      final fileSize = await downloadService.getFileSize(filePath);
      item = item.copyWith(
        status: DownloadStatus.completed,
        filePath: filePath,
        progress: 1.0,
        fileSizeBytes: fileSize,
        completedAt: DateTime.now(),
      );

      await repo.saveDownload(item);
      _ref.read(downloadsProvider.notifier).updateItem(item);
      _ref.read(settingsProvider.notifier).incrementDownloadCount();

      // Step 4: Generate thumbnail (non-blocking — don't fail the download)
      if (!isAudioOnly) {
        debugPrint('[Download] Generating thumbnail for video: $filePath');
        final thumbPath = await ThumbnailService.generateThumbnail(
          videoPath: filePath,
          itemId: id,
        );
        debugPrint('[Download] Thumbnail result: $thumbPath');
        if (thumbPath != null) {
          item = item.copyWith(thumbnailPath: thumbPath);
          await repo.saveDownload(item);
          _ref.read(downloadsProvider.notifier).updateItem(item);
        }
      } else {
        debugPrint('[Download] Skipping thumbnail - audio only');
      }

      state = ActiveDownloadState(currentItem: item);
      await ForegroundDownloadService.stopService();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        item = item.copyWith(status: DownloadStatus.cancelled);
        await repo.saveDownload(item);
        _ref.read(downloadsProvider.notifier).updateItem(item);
        state = const ActiveDownloadState();
        await ForegroundDownloadService.stopService();
        return;
      }

      String errorMsg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMsg = 'Cannot connect to download server. Is the backend running?';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Download timed out. Try again with lower quality.';
      } else {
        errorMsg = 'Download failed: ${e.message ?? 'Unknown error'}';
      }

      item = item.copyWith(
        status: DownloadStatus.failed,
        errorMessage: errorMsg,
      );
      await repo.saveDownload(item);
      _ref.read(downloadsProvider.notifier).updateItem(item);
      state = ActiveDownloadState(errorMessage: errorMsg);
      await ForegroundDownloadService.stopService();
    } catch (e) {
      final errorMsg = 'Download error: ${e.toString()}';
      item = item.copyWith(
        status: DownloadStatus.failed,
        errorMessage: errorMsg,
      );
      await repo.saveDownload(item);
      _ref.read(downloadsProvider.notifier).updateItem(item);
      state = ActiveDownloadState(errorMessage: errorMsg);
      await ForegroundDownloadService.stopService();
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    _cancelToken = null;
    ForegroundDownloadService.stopService();
  }

  void clearError() {
    state = const ActiveDownloadState();
  }
}

// ─── URL Input Provider ──────────────────────────────
final urlInputProvider = StateProvider<String>((ref) => '');

// ─── Search Query Provider ───────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

// ─── Filtered Downloads ──────────────────────────────
final filteredDownloadsProvider = Provider<List<DownloadItem>>((ref) {
  final downloads = ref.watch(downloadsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return downloads;

  return downloads
      .where((d) =>
          d.fileName.toLowerCase().contains(query) ||
          d.platform.toLowerCase().contains(query))
      .toList();
});

// ─── Storage Usage Provider ──────────────────────────
final storageUsageProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(downloadRepoProvider);
  return repo.getTotalStorageUsed();
});

// ─── Bottom Nav Index ────────────────────────────────
final bottomNavIndexProvider = StateProvider<int>((ref) => 0); // Home is first tab
