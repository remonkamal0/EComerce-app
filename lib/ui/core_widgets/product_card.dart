import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'add_to_cart_animation.dart';
import '../../domain/models/models.dart';
import '../view_models/auth_view_model.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/products/product_details_screen.dart';
import 'appliance_image.dart';
import 'product_price_view.dart';

/// Micro-interaction: scale down on touch and spring back with smooth curve
class _ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleOnPress({required this.child, required this.onTap});

  @override
  State<_ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<_ScaleOnPress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Animated Wishlist heart with elastic pop effect on tap
class _AnimatedWishlistButton extends StatefulWidget {
  final bool isInWishlist;
  final VoidCallback onTap;

  const _AnimatedWishlistButton({
    required this.isInWishlist,
    required this.onTap,
  });

  @override
  State<_AnimatedWishlistButton> createState() =>
      _AnimatedWishlistButtonState();
}

class _AnimatedWishlistButtonState extends State<_AnimatedWishlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (context.isDarkMode ? AppColors.darkCard : Colors.white)
                .withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isInWishlist ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: widget.isInWishlist
                  ? (context.isDarkMode
                        ? AppColors.primaryLight
                        : AppColors.primary)
                  : context.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Add to Cart button with scale bounce
class _AnimatedAddToCartButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedAddToCartButton({required this.onTap});

  @override
  State<_AnimatedAddToCartButton> createState() =>
      _AnimatedAddToCartButtonState();
}

class _AnimatedAddToCartButtonState extends State<_AnimatedAddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.82),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.82, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_shopping_cart,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Complete Product Grid Card with OpenContainer container transform & press micro-animations
class ProductGridCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddToCart;
  final bool isInWishlist;
  final Widget Function(BuildContext context, VoidCallback closeContainer)?
  openBuilder;

  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
    required this.onWishlistTap,
    required this.onAddToCart,
    this.isInWishlist = false,
    this.openBuilder,
  });

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final onTap = widget.onTap;
    final onWishlistTap = widget.onWishlistTap;
    final onAddToCart = widget.onAddToCart;
    final isInWishlist = widget.isInWishlist;
    final openBuilder = widget.openBuilder;
    return OpenContainer(
      tappable: false,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: context.scaffoldBg,
      middleColor: context.surfaceBg,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      transitionDuration: const Duration(milliseconds: 480),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, closeContainer) {
        if (openBuilder != null) {
          return openBuilder(context, closeContainer);
        }
        return ProductDetailsScreen(product: product);
      },
      closedBuilder: (context, openContainer) {
        return _ScaleOnPress(
          onTap: () {
            if (onTap != null) {
              onTap();
            } else {
              openContainer();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Stack with badges
                Expanded(
                  flex: 11,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: ApplianceImage(
                            key: _imageKey,
                            imageUrl: product.images.isNotEmpty
                                ? product.images.first
                                : '',
                            borderRadius: 0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (product.discountPercent > 0)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _AnimatedWishlistButton(
                          isInWishlist: isInWishlist,
                          onTap: onWishlistTap,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.productName(product.id, product.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.ratingStar,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '(${product.reviewCount})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ProductPriceView(
                              price: product.price,
                              originalPrice: product.originalPrice,
                              isCompact: true,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Builder(
                            builder: (ctx) {
                              final auth = ctx.watch<AuthViewModel>();
                              return _AnimatedAddToCartButton(
                                onTap: () {
                                  if (!auth.isAuthenticated) {
                                    Navigator.of(ctx).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignInScreen(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(ctx)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ctx.l10nRead.tr(
                                              'sign_in_cart_snack',
                                            ),
                                          ),
                                          backgroundColor: AppColors.primary,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    return;
                                  }
                                  AddToCartOverlayScope.maybeOf(ctx)?.flyToCart(
                                    sourceKey: _imageKey,
                                    imageUrl: product.images.isNotEmpty
                                        ? product.images.first
                                        : null,
                                  );
                                  onAddToCart();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal Offer Card with OpenContainer container transform & press animations
class ProductOfferCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Widget Function(BuildContext context, VoidCallback closeContainer)?
  openBuilder;

  const ProductOfferCard({
    super.key,
    required this.product,
    this.onTap,
    this.openBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      tappable: false,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: context.scaffoldBg,
      middleColor: context.surfaceBg,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      transitionDuration: const Duration(milliseconds: 480),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, closeContainer) {
        final customBuilder = openBuilder;
        if (customBuilder != null) {
          return customBuilder(context, closeContainer);
        }
        return ProductDetailsScreen(product: product);
      },
      closedBuilder: (context, openContainer) {
        return _ScaleOnPress(
          onTap: () {
            final tapHandler = onTap;
            if (tapHandler != null) {
              tapHandler();
            } else {
              openContainer();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.2 : 0.03,
                  ),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image with discount badge
                Stack(
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: ApplianceImage(
                        imageUrl: product.images.isNotEmpty
                            ? product.images.first
                            : '',
                        borderRadius: 12,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (product.discountPercent > 0)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.actionColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discountPercent}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.productName(product.id, product.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ProductPriceView(
                        price: product.price,
                        originalPrice: product.originalPrice,
                        isCompact: false,
                      ),
                    ],
                  ),
                ),

                // Green circle action arrow
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.actionColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.actionColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
