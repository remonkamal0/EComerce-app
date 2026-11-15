import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/models.dart';
import 'appliance_image.dart';

class CategoryGridCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ApplianceImage(
                imageUrl: category.image,
                borderRadius: 10,
                fit: BoxFit.contain,
                backgroundColor: context.cardBg,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.id.isNotEmpty
                        ? context.l10n.categoryName(category.id, category.name)
                        : category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: context.textSecondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryHomeShortcut extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryHomeShortcut({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 72,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.surfaceBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor, width: 0.8),
            ),
            child: ApplianceImage(
              imageUrl: category.image,
              borderRadius: 12,
              fit: BoxFit.cover,
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              category.id.isNotEmpty
                  ? context.l10n.categoryName(category.id, category.name)
                  : category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCompactCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCompactCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 0.8),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ApplianceImage(
                imageUrl: category.image,
                borderRadius: 8,
                fit: BoxFit.contain,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.id.isNotEmpty
                  ? context.l10n.categoryName(category.id, category.name)
                  : category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category tile with a large image and a two-line label area.
class CategoryCatalogCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCatalogCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.borderColor.withValues(alpha: isDark ? 0.9 : 0.65),
              width: 0.9,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.045),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: ApplianceImage(
                    imageUrl: category.image,
                    borderRadius: 12,
                    fit: BoxFit.cover,
                    backgroundColor: context.mintLightBg,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.textScalerOf(context).scale(13) * 2.5 + 8,
                child: Center(
                  child: Text(
                    context.l10n.categoryName(category.id, category.name),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
