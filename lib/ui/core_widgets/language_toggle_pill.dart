import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../view_models/app_theme_view_model.dart';

/// Compact pill button in AppBars allowing one-tap toggling between English and Arabic.
class LanguageTogglePill extends StatelessWidget {
  const LanguageTogglePill({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<AppThemeViewModel>();
    final isArabic = themeVm.isRTL;
    final isDark = context.isDarkMode;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: context.mintBg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => themeVm.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: isDark ? Colors.white : accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isArabic ? 'EN' : 'عربي',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: isArabic ? null : 'Cairo',
                    color: isDark ? Colors.white : accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
