
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';

/// Downlo App Theme — "The Polished Lens"
/// Dual-mode: Dark ("Celestial Void") + Light ("Daybreak")
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  // ═══════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  /// Shared builder — colors are resolved dynamically from AppColors
  /// based on the current AppColors._isDarkMode flag.
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF8FAFC),
      primaryColor: AppColors.secondary,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: Color(0xFFFD9000),
              secondary: Color(0xFFFD9000),
              tertiary: Color(0xFFA0E0FF),
              surface: Color(0xFF0E0E0E),
              error: Color(0xFFFF7351),
              onPrimary: Color(0xFF462400),
              onSecondary: Color(0xFF462400),
              onSurface: Color(0xFFFFFFFF),
              onError: Color(0xFFFFFFFF),
            )
          : const ColorScheme.light(
              primary: Color(0xFFFD9000),
              secondary: Color(0xFFFD9000),
              tertiary: Color(0xFF045974),
              surface: Color(0xFFFFFFFF),
              error: Color(0xFFDC2626),
              onPrimary: Color(0xFFFFFFFF),
              onSecondary: Color(0xFF1E0C00),
              onSurface: Color(0xFF1E293B),
              onError: Color(0xFFFFFFFF),
            ),
      textTheme: GoogleFonts.notoSerifTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      useMaterial3: true,

      // ─── AppBar — Glassmorphic ─────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.appBarTitle,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFF9F9F9) : const Color(0xFF1E293B),
        ),
      ),

      // ─── Bottom Navigation ─────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: isDark
            ? const Color(0xFFA8BDA8)
            : const Color(0xFF6B8E6B),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        elevation: 0,
      ),

      // ─── Bottom Sheet ──────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? const Color(0xFF191919)
            : const Color(0xFFFFFFFF),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ─── Dialog ────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1F1F1F)
            : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ─── Snackbar ──────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1F1F1F)
            : const Color(0xFF1E293B),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFFF8FAFC),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Input — Void / Canvas Style ───────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: (isDark ? const Color(0xFFABABAB) : const Color(0xFF64748B))
              .withValues(alpha: 0.4),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.2)
                : const Color(0xFF1E293B).withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.2)
                : const Color(0xFF1E293B).withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFFFD9000), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFF7351) : const Color(0xFFDC2626),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFFF7351) : const Color(0xFFDC2626),
            width: 1,
          ),
        ),
      ),

      // ─── Elevated Button ───────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: isDark
              ? const Color(0xFF462400)
              : const Color(0xFFFFFFFF),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ─── Text Button ───────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? const Color(0xFFA0E0FF)
              : const Color(0xFF045974),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      // ─── Outlined Button ───────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? const Color(0xFFF9F9F9)
              : const Color(0xFF1E293B),
          side: BorderSide(
            color: isDark
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.2)
                : const Color(0xFF1E293B).withValues(alpha: 0.15),
            width: 1,
          ),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ─── Divider — Avoid per design system ─────────
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
      ),

      // ─── Icon ──────────────────────────────────────
      iconTheme: IconThemeData(
        color: isDark
            ? const Color(0xFFA8BDA8)
            : const Color(0xFF6B8E6B),
        size: 24,
      ),
    );
  }
}
