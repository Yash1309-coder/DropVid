import 'package:flutter/material.dart';

/// Downlo Color Palette — "The Polished Lens"
///
/// Dual-palette architecture: Dark ("Celestial Void") + Light ("Daybreak").
/// All getters are dynamic — they resolve based on the current theme mode.
class AppColors {
  AppColors._();

  /// Current theme state — managed by ThemeModeNotifier
  static bool _isDarkMode = true;

  /// Set the current theme mode (called by ThemeModeNotifier)
  static void setDarkMode(bool value) => _isDarkMode = value;

  /// Read the current theme mode
  static bool get isDarkMode => _isDarkMode;

  // ═══════════════════════════════════════════════════════
  // BRAND / PRIMARY — High-emphasis text & navigation
  // ═══════════════════════════════════════════════════════
  static Color get primary =>
      _isDarkMode ? const Color(0xFFF9F9F9) : const Color(0xFF1E293B);

  static Color get primaryDim =>
      _isDarkMode ? const Color(0xFFEBEBEB) : const Color(0xFF334155);

  static Color get primaryContainer =>
      _isDarkMode ? const Color(0xFFA0A1A1) : const Color(0xFF94A3B8);

  static Color get onPrimary =>
      _isDarkMode ? const Color(0xFF5E5F60) : const Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════
  // SECONDARY (Orange) — Hero moments & primary CTAs
  // ═══════════════════════════════════════════════════════
  /// Orange stays consistent across themes for brand identity
  static const Color secondary = Color(0xFFFD9000);
  static const Color secondaryDim = Color(0xFFEA8400);
  static Color get secondaryContainer =>
      _isDarkMode ? const Color(0xFF8E4E00) : const Color(0xFFFFE0B2);

  static Color get onSecondary =>
      _isDarkMode ? const Color(0xFF462400) : const Color(0xFF1E0C00);

  // ═══════════════════════════════════════════════════════
  // TERTIARY (Blue) — Links & interactive pathways
  // ═══════════════════════════════════════════════════════
  static Color get tertiary =>
      _isDarkMode ? const Color(0xFFA0E0FF) : const Color(0xFF045974);

  static Color get tertiaryDim =>
      _isDarkMode ? const Color(0xFF72C6EB) : const Color(0xFF095B76);

  static Color get tertiaryContainer =>
      _isDarkMode ? const Color(0xFF81D4FA) : const Color(0xFFC0E9FF);

  // ═══════════════════════════════════════════════════════
  // SURFACES — "Luminous Depth" (Dark) / "Soft Canvas" (Light)
  // ═══════════════════════════════════════════════════════
  static Color get background =>
      _isDarkMode ? const Color(0xFF000000) : const Color(0xFFF8FAFC);

  static Color get surface =>
      _isDarkMode ? const Color(0xFF0E0E0E) : const Color(0xFFFFFFFF);

  static Color get surfaceDim =>
      _isDarkMode ? const Color(0xFF0E0E0E) : const Color(0xFFF1F5F9);

  static Color get surfaceBright =>
      _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF);

  static Color get surfaceContainerLowest =>
      _isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

  static Color get surfaceContainerLow =>
      _isDarkMode ? const Color(0xFF131313) : const Color(0xFFF1F5F9);

  static Color get surfaceContainer =>
      _isDarkMode ? const Color(0xFF191919) : const Color(0xFFE2E8F0);

  static Color get surfaceContainerHigh =>
      _isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFCBD5E1);

  static Color get surfaceContainerHighest =>
      _isDarkMode ? const Color(0xFF262626) : const Color(0xFF94A3B8);

  static Color get surfaceVariant =>
      _isDarkMode ? const Color(0xFF262626) : const Color(0xFFE2E8F0);

  // ═══════════════════════════════════════════════════════
  // ON-SURFACE
  // ═══════════════════════════════════════════════════════
  static Color get onSurface =>
      _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B);

  static Color get onSurfaceVariant =>
      _isDarkMode ? const Color(0xFFABABAB) : const Color(0xFF64748B);

  static Color get onBackground =>
      _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B);

  // ═══════════════════════════════════════════════════════
  // OUTLINE
  // ═══════════════════════════════════════════════════════
  static Color get outline =>
      _isDarkMode ? const Color(0xFF757575) : const Color(0xFF94A3B8);

  static Color get outlineVariant =>
      _isDarkMode ? const Color(0xFF484848) : const Color(0xFFE2E8F0);

  // ═══════════════════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════════════════
  /// Muted sage green for secondary utility icons
  static Color get sageMuted =>
      _isDarkMode ? const Color(0xFFA8BDA8) : const Color(0xFF6B8E6B);

  // ═══════════════════════════════════════════════════════
  // SEMANTIC
  // ═══════════════════════════════════════════════════════
  static Color get error =>
      _isDarkMode ? const Color(0xFFFF7351) : const Color(0xFFDC2626);

  static Color get errorDim =>
      _isDarkMode ? const Color(0xFFD53D18) : const Color(0xFFB91C1C);

  static Color get errorContainer =>
      _isDarkMode ? const Color(0xFFB92902) : const Color(0xFFFEE2E2);

  static Color get success =>
      _isDarkMode ? const Color(0xFF00D4AA) : const Color(0xFF16A34A);

  static Color get warning =>
      _isDarkMode ? const Color(0xFFFFB340) : const Color(0xFFD97706);

  static Color get info =>
      _isDarkMode ? const Color(0xFF4DA6FF) : const Color(0xFF2563EB);

  // ═══════════════════════════════════════════════════════
  // INVERSE
  // ═══════════════════════════════════════════════════════
  static Color get inverseSurface =>
      _isDarkMode ? const Color(0xFFF9F9F9) : const Color(0xFF1E293B);

  static Color get inversePrimary =>
      _isDarkMode ? const Color(0xFF5E5F60) : const Color(0xFFF8FAFC);

  static Color get inverseOnSurface =>
      _isDarkMode ? const Color(0xFF555555) : const Color(0xFFF1F5F9);

  // ═══════════════════════════════════════════════════════
  // LEGACY ALIASES — backward compatibility
  // ═══════════════════════════════════════════════════════
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static Color get grey900 => background;
  static Color get grey800 => surfaceContainerHigh;
  static Color get grey700 => surfaceContainer;
  static Color get grey600 => outlineVariant;
  static Color get grey400 => onSurfaceVariant;
  static Color get grey200 =>
      _isDarkMode ? const Color(0xFFB0B0C8) : const Color(0xFFCBD5E1);
  static Color get accent => secondary;

  // ═══════════════════════════════════════════════════════
  // PLATFORM COLORS — always static
  // ═══════════════════════════════════════════════════════
  static const Color instagram = Color(0xFFE1306C);
  static const Color tiktok = Color(0xFF010101);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color facebook = Color(0xFF1877F2);
  static const Color reddit = Color(0xFFFF4500);
  static const Color pinterest = Color(0xFFE60023);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color vimeo = Color(0xFF1AB7EA);
  static const Color dailymotion = Color(0xFF0066DC);

  // ═══════════════════════════════════════════════════════
  // GRADIENTS — theme-aware
  // ═══════════════════════════════════════════════════════
  /// Orange CTA gradient — consistent across themes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFD9000), Color(0xFFEA8400)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Radial glow for the Event Horizon button
  static RadialGradient get eventHorizonGradient => _isDarkMode
      ? const RadialGradient(
          colors: [Color(0xFF000000), Color(0xFF000000), Color(0x33FFFFFF)],
          stops: [0.0, 0.65, 1.0],
          center: Alignment.center,
          radius: 0.5,
        )
      : const RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0x33FD9000)],
          stops: [0.0, 0.65, 1.0],
          center: Alignment.center,
          radius: 0.5,
        );

  /// Progress bar gradient
  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFFFD9000), Color(0xFFEA8400)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Get platform color from string
  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return instagram;
      case 'tiktok':
        return tiktok;
      case 'twitter':
      case 'x':
        return twitter;
      case 'facebook':
        return facebook;
      case 'reddit':
        return reddit;
      case 'pinterest':
        return pinterest;
      case 'snapchat':
        return snapchat;
      case 'vimeo':
        return vimeo;
      case 'dailymotion':
        return dailymotion;
      default:
        return secondary;
    }
  }
}
