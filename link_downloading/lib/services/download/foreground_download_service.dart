import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Manages an Android foreground service so downloads survive
/// when the app is in the background or the screen is off.
///
/// The service shows a persistent notification with download progress.
class ForegroundDownloadService {
  static bool _initialized = false;

  /// One-time init — call from main() or before first download.
  static Future<void> init() async {
    if (_initialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'downlo_download_channel',
        channelName: 'Downloads',
        channelDescription: 'Shows progress while downloading media.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
        eventAction: ForegroundTaskEventAction.nothing(),
      ),
    );

    _initialized = true;
  }

  /// Start the foreground service before beginning a download.
  static Future<void> startService({String title = 'Downloading...'}) async {
    await init();
    await FlutterForegroundTask.startService(
      notificationTitle: title,
      notificationText: 'Preparing download...',
      callback: _startCallback,
    );
  }

  /// Update the notification with download progress.
  static Future<void> updateProgress({
    required String title,
    required double progress,
  }) async {
    final pct = (progress * 100).toInt().clamp(0, 100);
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: 'Downloading... $pct%',
    );
  }

  /// Stop the foreground service when download completes or is cancelled.
  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}

// Required top-level callback for flutter_foreground_task.
// Our downloads run on the main isolate, so this is essentially a no-op.
@pragma('vm:entry-point')
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(_DownloadTaskHandler());
}

class _DownloadTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
