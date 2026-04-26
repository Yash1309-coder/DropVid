import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'app_providers.dart';

/// Theme Mode Provider — persists user's day/night preference
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.light) {
    // Sync AppColors on initialization (light by default)
    AppColors.setDarkMode(false);
  }

  /// Load saved theme preference from settings
  void loadFromSettings() {
    final settings = _ref.read(settingsProvider);
    final isDark = settings.isDarkMode;
    AppColors.setDarkMode(isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    final newIsDark = state == ThemeMode.light;
    AppColors.setDarkMode(newIsDark);
    state = newIsDark ? ThemeMode.dark : ThemeMode.light;
    // Persist
    await _ref.read(settingsProvider.notifier).setDarkMode(newIsDark);
  }

  /// Set a specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    final isDark = mode == ThemeMode.dark;
    AppColors.setDarkMode(isDark);
    state = mode;
    await _ref.read(settingsProvider.notifier).setDarkMode(isDark);
  }
}
