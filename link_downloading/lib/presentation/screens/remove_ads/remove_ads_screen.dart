
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../providers/app_providers.dart';

/// Subscription Screen — "The Blackhole"
/// Matches Stitch subscription_overlay design.
class RemoveAdsScreen extends ConsumerWidget {
  const RemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // ─── SKIP Button ─────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      AppStrings.skip,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 3,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ─── Brand Title "Downlo" ─────────────
                Text(
                  AppStrings.subscriptionBrand,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                // Orange accent line
                Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 40),

                // ─── Headline ────────────────────────────
                Text(
                  AppStrings.subscriptionHeadline,
                  style: AppTypography.headlineLarge.copyWith(
                    fontSize: 26,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppStrings.subscriptionHeadlineItalic,
                  style: AppTypography.headlineLarge.copyWith(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ─── Body Text ───────────────────────────
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(text: '${AppStrings.subscriptionBody} '),
                      TextSpan(
                        text: '${AppStrings.subscriptionPrice}.',
                        style: TextStyle(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ─── Billing Disclaimer ──────────────────
                Text(
                  AppStrings.subscriptionBilling,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    letterSpacing: 2,
                    height: 1.8,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ─── SUBSCRIBE NOW Button ────────────────
                GestureDetector(
                  onTap: () {
                    // TODO: Integrate in-app purchase
                    ref.read(settingsProvider.notifier).markAdsRemoved();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.purchaseSuccess,
                            style: AppTypography.bodyMedium),
                        backgroundColor: AppColors.surfaceContainerHigh,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 260,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFD9000), Color(0xFFEA8400)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.subscribeNow,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.white,
                          letterSpacing: 3,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ─── Terms & Privacy Links ───────────────
                GestureDetector(
                  onTap: () {
                    // TODO: Open terms of use
                  },
                  child: Text(
                    AppStrings.seeTermsOfUse,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.tertiary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.tertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                  child: Text(
                    AppStrings.seePrivacyPolicy,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.tertiary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.tertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // ─── Restore Purchase ────────────────────
                GestureDetector(
                  onTap: () {
                    // TODO: Restore purchase
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.noPreviousPurchase,
                            style: AppTypography.bodyMedium),
                        backgroundColor: AppColors.surfaceContainerHigh,
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.restorePreviousPurchase,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
