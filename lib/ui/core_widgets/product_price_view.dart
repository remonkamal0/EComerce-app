import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../features/auth/sign_in_screen.dart';

class ProductPriceView extends StatelessWidget {
  final double price;
  final double originalPrice;
  final TextStyle? priceStyle;
  final TextStyle? originalPriceStyle;
  final bool isCompact;
  final CrossAxisAlignment crossAxisAlignment;

  const ProductPriceView({
    super.key,
    required this.price,
    this.originalPrice = 0.0,
    this.priceStyle,
    this.originalPriceStyle,
    this.isCompact = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    final accent = context.themeAccent;

    if (!auth.isAuthenticated) {
      // Guest User: Hide price and show "لمعرفة السعر سجل"
      return GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 10,
            vertical: isCompact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: context.mintBg,
            borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
            border: Border.all(color: accent.withValues(alpha: 0.45), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: isCompact ? 12 : 15,
                color: context.isDarkMode ? Colors.white : accent,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  context.tr('sign_in_for_price'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: context.isArabic ? 'Cairo' : null,
                    color: context.isDarkMode ? Colors.white : accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Authenticated User: Show real price
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${price.toInt()}',
          style:
              priceStyle ??
              TextStyle(
                fontSize: isCompact ? 16 : 22,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
        ),
        if (originalPrice > price)
          Text(
            '\$${originalPrice.toInt()}',
            style:
                originalPriceStyle ??
                TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textMuted,
                ),
          ),
      ],
    );
  }
}
