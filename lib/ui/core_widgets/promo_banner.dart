import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'appliance_image.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final String? imageUrl;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const PromoBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonText = 'Shop Now',
    this.imageUrl,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final christmas = context.isChristmasTheme;
    final bgColor = christmas
        ? AppColors.christmasGreen
        : backgroundColor ?? context.mintBg;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background subtle circles
            PositionedDirectional(
              end: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: context.isDarkMode ? 0.08 : 0.25,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: christmas
                                ? Colors.white
                                : context.textPrimaryColor,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: christmas
                                  ? Colors.white
                                  : context.textSecondaryColor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: context.actionColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    buttonText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (imageUrl != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 9,
                      child: ApplianceImage(
                        imageUrl: imageUrl!,
                        height: 116,
                        fit: BoxFit.cover,
                        borderRadius: 12,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
