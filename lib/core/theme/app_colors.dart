import 'package:flutter/material.dart';

/// Brand colours taken from the ALU Transport Figma file.
///
/// Every text colour is paired with a background that passes the
/// WCAG 4.5:1 contrast check (for example white on [primary] is about 5.4:1).
abstract final class AppColors {
  static const Color primary = Color(0xFF127A5B);
  static const Color primaryLight = Color(0xFFE7F5EF);
  static const Color primaryDark = Color(0xFF0B5A42);
  static const Color ink = Color(0xFF1B252D);
  static const Color muted = Color(0xFF55636E);
  static const Color outline = Color(0xFFD7DEE3);
  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFE8B64C);
  static const Color warningSurface = Color(0xFFFFF6E5);
  static const Color warningText = Color(0xFF7A4F00);
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerSurface = Color(0xFFFDE7E5);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoSurface = Color(0xFFEEF3FF);
  static const Color neutral = Color(0xFF55636E);
  static const Color neutralSurface = Color(0xFFEEF1F3);
  static const Color darkBackground = Color(0xFF0F1513);
  static const Color darkSurface = Color(0xFF18211E);
  static const Color darkOutline = Color(0xFF2C3A35);
  static const Color darkMuted = Color(0xFFA9B6BF);
  static const Color darkPrimary = Color(0xFF5FD3A8);
}
