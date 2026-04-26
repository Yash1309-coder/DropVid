import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/download/foreground_download_service.dart';
import 'data/models/hive_download_item.dart';
import 'data/models/hive_app_settings.dart';
import 'data/repositories/hive_download_repository.dart';
import 'data/repositories/hive_settings_repository.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HiveDownloadItemAdapter());
  Hive.registerAdapter(HiveAppSettingsAdapter());

  // Open boxes (initialize repositories)
  final downloadRepo = HiveDownloadRepository();
  await downloadRepo.init();

  final settingsRepo = HiveSettingsRepository();
  await settingsRepo.init();

  // Initialize foreground service (for background downloads)
  await ForegroundDownloadService.init();

  runApp(
    ProviderScope(
      overrides: [
        downloadRepoProvider.overrideWithValue(downloadRepo),
        settingsRepoProvider.overrideWithValue(settingsRepo),
      ],
      child: const _AppInitializer(),
    ),
  );
}

/// Widget that loads initial data before showing the app
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Load settings, downloads, and theme on startup
    Future.microtask(() {
      ref.read(settingsProvider.notifier).load();
      ref.read(downloadsProvider.notifier).load();
      // Sync theme from persisted settings
      ref.read(themeModeProvider.notifier).loadFromSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const DownloApp();
  }
}
