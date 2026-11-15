import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing values on an 8dp grid, used by every screen.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double radius = 14;
  static const double buttonRadius = 10;
}

/// Light and dark Material 3 themes built from the Figma colours.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? AppColors.darkPrimary : AppColors.primary,
          onPrimary: isDark ? const Color(0xFF00382A) : Colors.white,
          surface: isDark ? AppColors.darkSurface : AppColors.surface,
          onSurface: isDark ? const Color(0xFFE6ECEF) : AppColors.ink,
          outline: isDark ? AppColors.darkOutline : AppColors.outline,
          error: AppColors.danger,
        );

    final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    );

    const TextStyle buttonText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
          textStyle: buttonText,
          side: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: buttonText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isDark
            ? const Color(0xFF1F3D33)
            : AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
    );
  }
}

/// Short helpers so screens can write context.colors.primary
extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Secondary text colour that keeps 4.5:1 contrast in both themes.
  Color get mutedText => isDarkMode ? AppColors.darkMuted : AppColors.muted;
}
