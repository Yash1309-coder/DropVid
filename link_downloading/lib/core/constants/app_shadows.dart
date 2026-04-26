import 'package:flutter/material.dart';

/// Downlo Shadow Tokens
class AppShadows {
  AppShadows._();

  /// Card shadow — subtle elevation
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x40000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  /// Button shadow — purple-tinted glow
  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x556C63FF),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  /// Bottom sheet shadow — upward shadow
  static const BoxShadow sheetShadow = BoxShadow(
    color: Color(0x60000000),
    blurRadius: 24,
    offset: Offset(0, -4),
  );
}
