import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Downlo Typography — "The Storyteller's Hand"
///
/// Headline / Body: Noto Serif — editorial whimsy, storybook quality
/// Labels / Captions: Plus Jakarta Sans — clean, geometric, functional
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════
  // DISPLAY (Noto Serif)
  // ═══════════════════════════════════════════════════
  static TextStyle get displayLarge => GoogleFonts.notoSerif(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        letterSpacing: 8.0, // wide tracking for brand title
      );

  static TextStyle get displayMedium => GoogleFonts.notoSerif(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: AppColors.primary,
      );

  // ═══════════════════════════════════════════════════
  // HEADLINES (Noto Serif)
  // ═══════════════════════════════════════════════════
  static TextStyle get headlineLarge => GoogleFonts.notoSerif(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.notoSerif(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.primary,
      );

  static TextStyle get headlineSmall => GoogleFonts.notoSerif(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );

  // ═══════════════════════════════════════════════════
  // BODY (Noto Serif — editorial feel)
  // ═══════════════════════════════════════════════════
  static TextStyle get bodyLarge => GoogleFonts.notoSerif(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSerif(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.notoSerif(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 1.4,
      );

  // ═══════════════════════════════════════════════════
  // FILENAME (Noto Serif italic — each file is a story)
  // ═══════════════════════════════════════════════════
  static TextStyle get fileName => GoogleFonts.notoSerif(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.primary,
        letterSpacing: -0.3,
      );

  // ═══════════════════════════════════════════════════
  // LABELS (Plus Jakarta Sans — functional data layer)
  // ═══════════════════════════════════════════════════
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 1.5,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.2,
      );

  // ═══════════════════════════════════════════════════
  // CAPTION (Plus Jakarta Sans — technical meta)
  // ═══════════════════════════════════════════════════
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 2.5,
      );

  // ═══════════════════════════════════════════════════
  // APP BAR TITLE (Noto Serif italic — brand identity)
  // ═══════════════════════════════════════════════════
  static TextStyle get appBarTitle => GoogleFonts.notoSerif(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.primary,
        letterSpacing: -0.5,
      );
}
