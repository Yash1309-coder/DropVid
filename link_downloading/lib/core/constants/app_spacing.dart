import 'package:flutter/material.dart';

/// Downlo Spacing System
/// Base unit: 4px
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0; // Tight internal spacing
  static const double sm = 8.0; // Between icon and label
  static const double md = 12.0; // Between list items
  static const double lg = 16.0; // Screen horizontal padding
  static const double xl = 20.0; // Between sections
  static const double xxl = 24.0; // Card padding
  static const double xxxl = 32.0; // Between major sections
  static const double huge = 48.0; // Empty state illustration gap

  /// Standard screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  /// Card internal padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}

/// Downlo Border Radius Tokens
class AppRadius {
  AppRadius._();

  static const double sm = 8.0; // Chips, badges
  static const double md = 12.0; // Input fields
  static const double lg = 16.0; // Cards
  static const double xl = 20.0; // Bottom sheets, modals
  static const double xxl = 28.0; // Download button
  static const double full = 999.0; // Pills, avatar

  // Pre-built BorderRadius
  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
  static final BorderRadius xlRadius = BorderRadius.circular(xl);
  static final BorderRadius xxlRadius = BorderRadius.circular(xxl);
  static final BorderRadius fullRadius = BorderRadius.circular(full);
}
