import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/file_utils.dart';
import '../../../domain/entities/download_item.dart';
import '../../providers/app_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(filteredDownloadsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        SafeArea(child: Column(children: [
          const SizedBox(height: 72),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
              decoration: InputDecoration(
                hintText: AppStrings.searchHistory,
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 20),
                        onPressed: () => ref.read(searchQueryProvider.notifier).state = '') : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: downloads.isEmpty ? _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: downloads.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _VideoCard(item: downloads[index],
                    onDelete: () => _showDeleteDialog(context, ref, downloads[index]),
                    onTap: () => _onVideoTap(context, downloads[index]))),
              ),
          ),
        ])),
        _buildAppBar(context, ref),
      ]),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Positioned(top: 0, left: 0, right: 0,
      child: ClipRRect(child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.background.withValues(alpha: 0.7),
          child: SafeArea(bottom: false, child: SizedBox(height: 56,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(icon: Icon(Icons.arrow_back, color: AppColors.sageMuted, size: 24),
                  onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 0),
                const Spacer(),
                IconButton(icon: Icon(Icons.block, color: AppColors.sageMuted, size: 24),
                  onPressed: () => Navigator.pushNamed(context, '/remove-ads')),
              ]),
            ),
          )),
        ),
      )),
    );
  }

  void _onVideoTap(BuildContext context, DownloadItem item) {}

  void _showDeleteDialog(BuildContext context, WidgetRef ref, DownloadItem item) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      title: Text(AppStrings.deleteDownload, style: AppTypography.headlineSmall),
      content: Text(AppStrings.deleteBody, style: AppTypography.bodyMedium),
      actions: [
        TextButton(onPressed: () { Navigator.pop(ctx); ref.read(downloadsProvider.notifier).removeItem(item.id); },
          child: Text(AppStrings.recordOnly, style: TextStyle(color: AppColors.tertiary))),
        TextButton(onPressed: () { Navigator.pop(ctx); ref.read(downloadsProvider.notifier).removeItem(item.id, deleteFile: true); },
          child: Text(AppStrings.fileAndRecord, style: TextStyle(color: AppColors.error))),
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text(AppStrings.cancel, style: TextStyle(color: AppColors.onSurfaceVariant))),
      ],
    ));
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1))),
        child: Icon(Icons.video_library_outlined, size: 32, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4))),
      const SizedBox(height: 24),
      Text(AppStrings.noDownloadsYet, style: AppTypography.headlineSmall.copyWith(color: AppColors.primary.withValues(alpha: 0.8))),
      const SizedBox(height: 8),
      Text(AppStrings.noDownloadsBody, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
    ]));
  }
}

class _VideoCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  const _VideoCard({required this.item, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dismissible(key: Key(item.id), direction: DismissDirection.endToStart, onDismissed: (_) => onDelete(),
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_outline, color: AppColors.error)),
      child: GestureDetector(onTap: onTap,
        child: Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            // Thumbnail or fallback icon
            _buildThumbnail(),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_truncateFileName(item.fileName), style: AppTypography.fileName, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${FileUtils.formatFileSize(item.fileSizeBytes)} • ${_formatDuration(item)}', style: AppTypography.labelSmall),
            ])),
            GestureDetector(onTap: () => _showOptionsMenu(context), child: _DotGrid()),
          ]),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final thumbPath = item.thumbnailPath;
    final hasThumb = thumbPath != null && thumbPath.isNotEmpty && File(thumbPath).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 80,
        child: hasThumb
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(thumbPath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, st) => _fallbackIcon(),
                  ),
                  // Play icon overlay
                  Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(
        item.isAudioOnly ? Icons.audiotrack_rounded : Icons.play_arrow_rounded,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }

  String _truncateFileName(String name) => name.length > 12 ? '${name.substring(0, 8)}...${name.substring(name.length - 4)}' : name;

  String _formatDuration(DownloadItem item) {
    if (item.fileSizeBytes > 0) {
      final seconds = (item.fileSizeBytes / (1024 * 1024) * 10).round();
      return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    }
    return FileUtils.formatDate(item.createdAt);
  }

  void _showOptionsMenu(BuildContext context) {}
}

class _DotGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8),
      child: SizedBox(width: 18, height: 18, child: GridView.count(
        crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2, physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (_) => Container(decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle))),
      )),
    );
  }
}
