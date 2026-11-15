import 'package:flutter/material.dart';

class AppColors {
  static const christmasRed = Color(0xFFD91625);
  static const christmasGreen = Color(0xFF14784E);

  // Brand Primary & Mint
  static const Color primary = Color(0xFF086747); // Deep Emerald Green
  static const Color primaryDark = Color(0xFF054F36);
  static const Color primaryLight = Color(0xFF0B825B);
  static const Color mint = Color(0xFFE8F2EC); // Pale Mint Promotional Banner
  static const Color mintLight = Color(0xFFF3F9F5);
  static const Color mintDark = Color(0xFFD4E7DC);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F6F6);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEEEEEE);

  // Text Colors
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Feedback & Accents
  static const Color ratingStar = Color(0xFFF59E0B);
  static const Color discountRed = Color(0xFFDC2626);
  static const Color discountBg = Color(0xFFFEF2F2);
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark Mode Overrides
  static const Color darkBackground = Color(0xFF121415);
  static const Color darkSurface = Color(0xFF1E2124);
  static const Color darkCard = Color(0xFF25292D);
  static const Color darkBorder = Color(0xFF33383F);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkMint = Color(0xFF16382A);
}

/// Theme-adaptive color helpers for clean Light & Dark mode rendering.
extension AppThemeColorsX on BuildContext {
  bool get isChristmasTheme =>
      Theme.of(this).colorScheme.primary == AppColors.christmasRed;
  Color get themeAccent => Theme.of(this).colorScheme.primary;
  Color get actionColor => isChristmasTheme ? themeAccent : AppColors.primary;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get scaffoldBg => isDarkMode || isChristmasTheme
      ? Theme.of(this).scaffoldBackgroundColor
      : AppColors.background;
  Color get cardBg => isDarkMode
      ? Theme.of(this).cardTheme.color ?? AppColors.darkCard
      : AppColors.card;
  Color get surfaceBg => isDarkMode || isChristmasTheme
      ? Theme.of(this).colorScheme.surface
      : AppColors.surface;
  Color get surfaceLightBg =>
      isDarkMode ? const Color(0xFF181B1D) : AppColors.surfaceLight;
  Color get borderColor => isDarkMode
      ? Theme.of(this).dividerTheme.color ?? AppColors.darkBorder
      : AppColors.border;
  Color get dividerColor => isDarkMode
      ? Theme.of(this).dividerTheme.color ?? AppColors.darkBorder
      : AppColors.divider;
  Color get textPrimaryColor =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondaryColor =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get mintBg => isDarkMode || isChristmasTheme
      ? Theme.of(this).colorScheme.secondary
      : AppColors.mint;
  Color get mintLightBg =>
      isDarkMode ? const Color(0xFF132D22) : AppColors.mintLight;
}
