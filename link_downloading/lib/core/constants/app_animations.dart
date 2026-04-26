import 'package:flutter/material.dart';

/// Downlo Animation Constants
class AppAnimations {
  AppAnimations._();

  // ─── Durations ─────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration xslow = Duration(milliseconds: 600);

  // ─── Curves ────────────────────────────────────────
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
}
