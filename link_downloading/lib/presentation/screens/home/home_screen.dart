import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/platform_detector.dart';
import '../../../domain/entities/download_item.dart';
import '../../providers/app_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/quality_picker_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _urlController.dispose(); _focusNode.dispose(); _glowController.dispose(); super.dispose(); }

  void _onPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) { _urlController.text = data!.text!; ref.read(urlInputProvider.notifier).state = data.text!; }
  }

  void _onClear() { _urlController.clear(); ref.read(urlInputProvider.notifier).state = ''; ref.read(activeDownloadProvider.notifier).clearError(); }

  void _onDownload() {
    final url = _urlController.text.trim();
    if (url.isEmpty) { _onPaste(); return; }
    _focusNode.unfocus();
    QualityPickerSheet.show(context, url: url);
  }

  @override
  Widget build(BuildContext context) {
    final activeDownload = ref.watch(activeDownloadProvider);
    final isDownloading = activeDownload.isDownloading;
    final currentItem = activeDownload.currentItem;
    final errorMessage = activeDownload.errorMessage;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        _buildStarField(isDark),
        SafeArea(child: Column(children: [
          const SizedBox(height: 80),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              Text(AppStrings.appTagline, style: AppTypography.displayLarge.copyWith(
                fontSize: 42, color: AppColors.primary.withValues(alpha: 0.9), letterSpacing: 6.0)),
              SizedBox(height: screenHeight * 0.03),
              _buildEventHorizon(isDownloading, currentItem, isDark),
              SizedBox(height: screenHeight * 0.05),
              if (errorMessage != null) ...[
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(errorMessage, style: AppTypography.bodySmall.copyWith(color: AppColors.error))),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (isDownloading && currentItem != null) ...[_buildProgressIndicator(currentItem), const SizedBox(height: 16)],
              if (!isDownloading && currentItem != null && currentItem.status == DownloadStatus.completed) ...[
                _buildCompletedIndicator(currentItem), const SizedBox(height: 16)],
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _urlController, focusNode: _focusNode,
                  onChanged: (v) => ref.read(urlInputProvider.notifier).state = v,
                  onSubmitted: (_) => _onDownload(),
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: AppStrings.urlPlaceholder,
                    hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                    suffixIcon: _urlController.text.isNotEmpty
                        ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 20), onPressed: _onClear) : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDotGridLabel(),
              const SizedBox(height: 40),
            ]),
          )),
        ])),
        _buildAppBar(context, isDark),
      ]),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Positioned(top: 0, left: 0, right: 0,
      child: ClipRRect(child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.background.withValues(alpha: 0.7),
          child: SafeArea(bottom: false, child: SizedBox(height: 56,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(icon: Icon(Icons.menu, color: AppColors.primary, size: 24),
                  onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2),
                Text(AppStrings.appNameStyled, style: AppTypography.appBarTitle),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                      key: ValueKey(isDark), color: AppColors.primary, size: 24)),
                  onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                ),
              ]),
            ),
          )),
        ),
      )),
    );
  }

  Widget _buildEventHorizon(bool isDownloading, DownloadItem? currentItem, bool isDark) {
    return AnimatedBuilder(animation: _glowController, builder: (context, child) {
      final glowOpacity = 0.05 + (_glowController.value * 0.08);
      final glowColor = isDownloading
          ? AppColors.secondary.withValues(alpha: glowOpacity)
          : (isDark ? AppColors.white : AppColors.secondary).withValues(alpha: glowOpacity);
      return GestureDetector(onTap: isDownloading ? null : _onDownload,
        child: Stack(alignment: Alignment.center, children: [
          Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: glowColor, blurRadius: 80, spreadRadius: 20)])),
          Container(width: 256, height: 256, decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.eventHorizonGradient,
            border: Border.all(color: (isDark ? AppColors.white : AppColors.secondary).withValues(alpha: 0.15), width: 1),
            boxShadow: [BoxShadow(color: (isDark ? AppColors.white : AppColors.secondary).withValues(alpha: 0.1), blurRadius: 50)],
          ),
            child: Center(child: isDownloading && currentItem != null
                ? _buildSphereProgress(currentItem)
                : Icon(Icons.download, color: (isDark ? AppColors.white : AppColors.secondary).withValues(alpha: 0.9), size: 48)),
          ),
        ]),
      );
    });
  }

  /// Status label for pre-download phases
  String _statusLabel(DownloadItem item) {
    switch (item.status) {
      case DownloadStatus.resolving:
        return 'Finding video…';
      case DownloadStatus.fetching:
        return 'Server downloading ${(item.progress * 100).toStringAsFixed(0)}%';
      case DownloadStatus.merging:
        return 'Merging streams…';
      case DownloadStatus.downloading:
        return '${(item.progress * 100).toStringAsFixed(0)}%';
      default:
        return '${(item.progress * 100).toStringAsFixed(0)}%';
    }
  }

  Widget _buildSphereProgress(DownloadItem item) {
    final isPreDownload = item.status == DownloadStatus.resolving ||
        item.status == DownloadStatus.fetching ||
        item.status == DownloadStatus.merging;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 48, height: 48, child: CircularProgressIndicator(
        // Show indeterminate spinner during resolving/merging, determinate during fetching/downloading
        value: (item.status == DownloadStatus.resolving || item.status == DownloadStatus.merging)
            ? null
            : (item.progress > 0 ? item.progress : null),
        color: AppColors.secondary, backgroundColor: AppColors.primary.withValues(alpha: 0.1), strokeWidth: 2)),
      const SizedBox(height: 8),
      Text(
        isPreDownload ? _statusLabel(item) : '${(item.progress * 100).toStringAsFixed(0)}%',
        style: AppTypography.labelSmall.copyWith(color: AppColors.secondary, fontSize: isPreDownload ? 9 : 12),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  Widget _buildProgressIndicator(DownloadItem item) {
    final isPreDownload = item.status == DownloadStatus.resolving ||
        item.status == DownloadStatus.fetching ||
        item.status == DownloadStatus.merging;

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(children: [
        // Show status label during pre-download, filename during actual download
        Text(
          isPreDownload ? _statusLabel(item) : item.fileName,
          style: AppTypography.fileName.copyWith(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(2),
          child: SizedBox(height: 2, child: LinearProgressIndicator(
            value: (item.status == DownloadStatus.resolving || item.status == DownloadStatus.merging)
                ? null // Indeterminate
                : (item.progress > 0 ? item.progress : null),
            color: AppColors.secondary, backgroundColor: AppColors.primary.withValues(alpha: 0.1)))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(PlatformDetector.getDisplayName(item.platform), style: AppTypography.caption),
          const SizedBox(width: 16),
          GestureDetector(onTap: () => ref.read(activeDownloadProvider.notifier).cancelDownload(),
            child: Text('CANCEL', style: AppTypography.caption.copyWith(color: AppColors.error, letterSpacing: 2))),
        ]),
      ]),
    );
  }

  Widget _buildCompletedIndicator(DownloadItem item) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(children: [
        Icon(Icons.check_circle_outline, color: AppColors.success, size: 24),
        const SizedBox(height: 6),
        Text(AppStrings.downloadComplete,
          style: AppTypography.labelSmall.copyWith(color: AppColors.success, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(item.fileName, style: AppTypography.caption, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildDotGridLabel() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        child: Column(children: [
          Container(
            width: 48, height: 48,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 1),
            ),
            child: GridView.count(
              crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(9, (_) => Container(
                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle))),
            ),
          ),
          const SizedBox(height: 10),
          Text(AppStrings.videosLabel, style: AppTypography.caption.copyWith(
            color: AppColors.onSurfaceVariant, letterSpacing: 3)),
        ]),
      ),
    );
  }

  Widget _buildStarField(bool isDark) {
    final starColor = isDark ? AppColors.white : AppColors.onSurfaceVariant;
    final size = MediaQuery.of(context).size;
    return Stack(children: [
      Positioned(top: size.height * 0.25, left: size.width * 0.25,
        child: Container(width: 1, height: 1, decoration: BoxDecoration(color: starColor,
          boxShadow: [BoxShadow(color: starColor.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)]))),
      Positioned(top: size.height * 0.5, right: size.width * 0.33,
        child: Container(width: 1, height: 1, decoration: BoxDecoration(color: starColor,
          boxShadow: [BoxShadow(color: starColor.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]))),
      Positioned(bottom: size.height * 0.25, left: size.width * 0.5,
        child: Container(width: 1, height: 1, decoration: BoxDecoration(color: starColor,
          boxShadow: [BoxShadow(color: starColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 3)]))),
    ]);
  }
}
