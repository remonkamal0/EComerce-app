import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HomePlusIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HomePlusIcon({
    super.key,
    this.size = 36,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color == AppColors.primary && context.isDarkMode
        ? AppColors.primaryLight
        : color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.mintBg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: size * 0.75,
              color: resolvedColor,
            ),
            Positioned(
              bottom: size * 0.16,
              child: Icon(
                Icons.power,
                size: size * 0.35,
                color: resolvedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showTagline;
  final bool isHorizontal;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.iconSize = 36,
    this.showTagline = false,
    this.isHorizontal = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = RichText(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Home',
            style: TextStyle(
              fontSize: iconSize * 0.65,
              fontWeight: FontWeight.w800,
              color: textColor ?? context.textPrimaryColor,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Plus',
            style: TextStyle(
              fontSize: iconSize * 0.65,
              fontWeight: FontWeight.w800,
              color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );

    if (isHorizontal) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomePlusIcon(size: iconSize),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                if (showTagline) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Your Home. Our Priority.',
                    style: TextStyle(
                      fontSize: iconSize * 0.28,
                      fontWeight: FontWeight.w500,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HomePlusIcon(size: iconSize),
        const SizedBox(height: 12),
        titleWidget,
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Your Home. Our Priority.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

