import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/utils/file_utils.dart';
import '../../../domain/entities/app_settings.dart';
import '../../providers/app_providers.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final storageUsage = ref.watch(storageUsageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  _ThemeToggle(isDark: isDark, ref: ref),
                  const SizedBox(height: 28),
                  _SectionLabel('Download'),
                  const SizedBox(height: 12),
                  _SettingsGroup(children: [
                    _SettingsTile(
                      icon: Icons.high_quality_rounded,
                      title: AppStrings.videoQuality,
                      trailing: _QualityDropdown(
                        value: settings.preferredQuality,
                        onChanged: (q) => ref.read(settingsProvider.notifier).setQuality(q),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.audiotrack_rounded,
                      title: AppStrings.audioOnly,
                      subtitle: AppStrings.audioOnlyDescription,
                      trailing: Switch(
                        value: settings.audioOnly,
                        onChanged: (_) => ref.read(settingsProvider.notifier).toggleAudioOnly(),
                        activeThumbColor: AppColors.secondary,
                        activeTrackColor: AppColors.secondary.withValues(alpha: 0.3),
                        inactiveTrackColor: AppColors.outlineVariant,
                        inactiveThumbColor: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  _SectionLabel('Storage'),
                  const SizedBox(height: 12),
                  _SettingsGroup(children: [
                    _SettingsTile(
                      icon: Icons.storage_rounded,
                      title: AppStrings.storageUsage,
                      trailing: storageUsage.when(
                        data: (bytes) => Text(FileUtils.formatFileSize(bytes),
                            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                        loading: () => SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary)),
                        error: (_, _) => Text('—', style: AppTypography.bodyMedium),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      title: AppStrings.clearCache,
                      subtitle: 'Clear temporary files',
                      onTap: () => _showClearCacheDialog(context, ref),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  if (!settings.adsRemoved) ...[
                    _SectionLabel('Premium'),
                    const SizedBox(height: 12),
                    _SettingsGroup(children: [
                      _SettingsTile(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.secondary,
                        title: AppStrings.removeAds,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
                        onTap: () => Navigator.of(context).pushNamed('/remove-ads'),
                      ),
                    ]),
                    const SizedBox(height: 28),
                  ],
                  _SectionLabel('About'),
                  const SizedBox(height: 12),
                  _SettingsGroup(children: [
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.privacyPolicy,
                      trailing: Icon(Icons.open_in_new_rounded, color: AppColors.onSurfaceVariant, size: 16),
                      onTap: () => launchUrl(Uri.parse('https://downlo.app/privacy')),
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: AppStrings.termsOfService,
                      trailing: Icon(Icons.open_in_new_rounded, color: AppColors.onSurfaceVariant, size: 16),
                      onTap: () => launchUrl(Uri.parse('https://downlo.app/terms')),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      trailing: Text(AppConfig.appVersion, style: AppTypography.labelSmall),
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildAppBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: AppColors.background.withValues(alpha: 0.7),
            child: SafeArea(bottom: false,
              child: SizedBox(height: 56,
                child: Center(child: Text(AppStrings.settings.toLowerCase(), style: AppTypography.appBarTitle)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      title: Text(AppStrings.clearCacheTitle, style: AppTypography.headlineSmall),
      content: Text(AppStrings.clearCacheBody, style: AppTypography.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text(AppStrings.cancel, style: TextStyle(color: AppColors.onSurfaceVariant))),
        TextButton(onPressed: () { Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cache cleared', style: AppTypography.bodyMedium),
            backgroundColor: AppColors.surfaceContainerHigh));},
          child: Text(AppStrings.clear, style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final WidgetRef ref;
  const _ThemeToggle({required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFFD9000), const Color(0xFFFBBF24)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                : const Color(0xFFFD9000).withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(anim),
              child: FadeTransition(opacity: anim, child: child)),
            child: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              key: ValueKey<bool>(isDark),
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFFFFFFF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isDark ? 'Night Mode' : 'Day Mode',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(isDark ? 'The Celestial Void' : 'Soft Daybreak',
              style: AppTypography.caption.copyWith(color: AppColors.white.withValues(alpha: 0.7), fontSize: 11)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400), width: 52, height: 28,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
              color: AppColors.white.withValues(alpha: isDark ? 0.15 : 0.35)),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 400), curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(width: 22, height: 22, margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white,
                  boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))])),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTypography.caption.copyWith(
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), letterSpacing: 3, fontSize: 10));
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, this.iconColor, required this.title, this.subtitle, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          Icon(icon, color: iconColor ?? AppColors.sageMuted, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontSize: 15)),
            if (subtitle != null) Text(subtitle!, style: AppTypography.caption.copyWith(fontSize: 11)),
          ])),
          ?trailing,
        ]),
      ),
    );
  }
}

class _QualityDropdown extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _QualityDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value, underline: const SizedBox(),
      dropdownColor: AppColors.surfaceContainerHigh,
      style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
      icon: Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
      items: AppSettings.qualityOptions.map((q) => DropdownMenuItem(value: q, child: Text(q == 'max' ? 'Max' : '${q}p'))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}
