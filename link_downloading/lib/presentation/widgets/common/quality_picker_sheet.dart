import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../providers/app_providers.dart';

class QualityPickerSheet extends ConsumerWidget {
  final String url;

  const QualityPickerSheet({super.key, required this.url});

  static void show(BuildContext context, {required String url}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QualityPickerSheet(url: url),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: AppColors.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Quality',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred download quality.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildQualityOption(
              context: context,
              ref: ref,
              title: 'Highest Quality',
              subtitle: 'Best available resolution',
              icon: Icons.hd_outlined,
              quality: 'max',
              isAudioOnly: false,
            ),
            _buildQualityOption(
              context: context,
              ref: ref,
              title: '1080p',
              subtitle: 'Full HD',
              icon: Icons.high_quality_outlined,
              quality: '1080',
              isAudioOnly: false,
            ),
            _buildQualityOption(
              context: context,
              ref: ref,
              title: '720p',
              subtitle: 'HD',
              icon: Icons.video_camera_front_outlined,
              quality: '720',
              isAudioOnly: false,
            ),
            _buildQualityOption(
              context: context,
              ref: ref,
              title: 'Audio Only',
              subtitle: 'MP3 / M4A format',
              icon: Icons.audiotrack_outlined,
              quality: 'max',
              isAudioOnly: true,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required String quality,
    required bool isAudioOnly,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          ref.read(activeDownloadProvider.notifier).startDownload(
            url,
            qualityOverride: quality,
            audioOnlyOverride: isAudioOnly,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
