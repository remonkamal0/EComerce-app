import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/core_widgets/product_price_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import '../auth/sign_in_screen.dart';
import '../products/product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const WishlistScreen({super.key, this.onNavigateTab});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Map<String, int> _quantities = {};

  int _getQty(String id) => _quantities[id] ?? 1;

  void _incrementQty(String id) {
    setState(() {
      _quantities[id] = _getQty(id) + 1;
    });
  }

  void _decrementQty(String id) {
    if (_getQty(id) > 1) {
      setState(() {
        _quantities[id] = _getQty(id) - 1;
      });
    }
  }

  void _showClearConfirmation(BuildContext context) {
    final wishlistVm = context.read<WishlistViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.tr('clear_wishlist_title')),
        content: Text(ctx.l10n.tr('clear_wishlist_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              wishlistVm.clearWishlist();
              Navigator.of(ctx).pop();
            },
            child: Text(ctx.l10n.tr('clear_all'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistVm = context.watch<WishlistViewModel>();
    final cartVm = context.read<CartViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr('my_wishlist_title')),
        actions: [
          if (!wishlistVm.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearConfirmation(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistVm.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border,
              title: context.tr('wishlist_empty_title'),
              message: context.tr('wishlist_empty_msg'),
              buttonText: context.tr('start_shopping'),
              onButtonPressed: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(0); // Switch to Home tab
                }
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth =
                    constraints.maxWidth.clamp(0.0, ResponsiveLayout.maxContentWidth);
                final hPad = ResponsiveLayout.horizontalPadding(effectiveWidth);
                final cols = ResponsiveLayout.cardListColumns(effectiveWidth);
                final contentWidth = effectiveWidth - (hPad * 2);
                final itemWidth = cols > 1
                    ? (contentWidth - (cols - 1) * 12) / cols
                    : contentWidth;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                        child: ResponsiveConstrainedBox(
                          child: StaggeredListLimiter(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: wishlistVm.items.asMap().entries.map((entry) {
                                final index = entry.key;
                                final product = entry.value;
                                final qty = _getQty(product.id);

                                return SizedBox(
                                  width: itemWidth,
                                  child: StaggeredListItem(
                                    index: index,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailsScreen(product: product),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: context.cardBg,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: context.borderColor, width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            // Image
                                            SizedBox(
                                              width: 84,
                                              height: 84,
                                              child: ApplianceImage(
                                                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                                                borderRadius: 12,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 14),

                                            // Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          context.l10n.productName(product.id, product.name),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700,
                                                            color: context.textPrimaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      // Filled green heart to remove
                                                      GestureDetector(
                                                        onTap: () => wishlistVm.removeFromWishlist(product.id),
                                                        child: const Icon(
                                                          Icons.favorite,
                                                          size: 20,
                                                          color: AppColors.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),

                                                  // Rating
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star, size: 14, color: AppColors.ratingStar),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        product.rating.toStringAsFixed(1),
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '(${product.reviewCount})',
                                                        style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),

                                                  // Price & Stepper
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: ProductPriceView(
                                                          price: product.price,
                                                          originalPrice: product.originalPrice,
                                                          isCompact: true,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),

                                                      // Quantity Stepper
                                                      Container(
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: context.surfaceBg,
                                                          borderRadius: BorderRadius.circular(15),
                                                          border: Border.all(color: context.borderColor, width: 0.8),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () => _decrementQty(product.id),
                                                              child: const Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                                child: Icon(Icons.remove, size: 14),
                                                              ),
                                                            ),
                                                            Text(
                                                              '$qty',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () => _incrementQty(product.id),
                                                              child: const Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                                child: Icon(Icons.add, size: 14),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Action: Add All to Cart
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
                        child: ResponsiveConstrainedBox(
                          maxWidth: ResponsiveLayout.maxFormWidth,
                          child: CustomButton(
                            text: context.tr('add_all_to_cart'),
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
                            onPressed: () async {
                              final auth = context.read<AuthViewModel>();
                              if (!auth.isAuthenticated) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                                );
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10nRead.tr('sign_in_wishlist_snack')),
                                      backgroundColor: AppColors.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                return;
                              }
                              final count = await wishlistVm.addAllToCart(cartVm);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10nRead.addedItemsToCartMsg(count)),
                                      backgroundColor: AppColors.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}


