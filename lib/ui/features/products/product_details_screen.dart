import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homeplus/ui/core_widgets/add_to_cart_animation.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/section_header.dart';
import 'package:homeplus/ui/core_widgets/product_card.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/core_widgets/product_price_view.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import '../auth/sign_in_screen.dart';
import '../cart/cart_screen.dart';
import 'compare_products_screen.dart';
import 'product_reviews_screen.dart';
import 'search_results_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _imageController = PageController();
  final GlobalKey _addButtonKey = GlobalKey();
  int _currentImageIndex = 0;
  int _quantity = 1;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _shareProduct(
    BuildContext buttonContext,
    Product product,
  ) async {
    final name = buttonContext.l10n.productName(product.id, product.name);
    final arabic = buttonContext.isArabic;
    final text = '$name\n\n${product.description}\n\nHomePlus';
    final box = buttonContext.findRenderObject();
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          title: name,
          subject: name,
          sharePositionOrigin: box is RenderBox && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
      if (!kIsWeb || result.status != ShareResultStatus.unavailable) return;
    } on PlatformException {
      // Browsers or devices without a share target can use the clipboard.
    } on MissingPluginException {
      // The clipboard is also available on platforms without a share plugin.
    }
    if (!mounted) return;
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(arabic ? 'تعذرت المشاركة' : 'Unable to share')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          arabic ? 'تم نسخ تفاصيل المنتج' : 'Product details copied',
        ),
      ),
    );
  }

  IconData _getFeatureIcon(String iconKey) {
    switch (iconKey) {
      case 'snowflake':
        return Icons.ac_unit;
      case 'bolt':
        return Icons.bolt;
      case 'shield':
        return Icons.verified_user_outlined;
      case 'box':
        return Icons.all_inbox;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'flame':
        return Icons.local_fire_department_outlined;
      case 'tv':
        return Icons.tv;
      case 'headphones':
        return Icons.headphones_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildGallery(
    BuildContext context,
    Product p,
    List<String> images,
    double height,
  ) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.surfaceLightBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _imageController,
            itemCount: images.length,
            onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
            itemBuilder: (context, index) {
              return ApplianceImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                borderRadius: 0,
                backgroundColor: Colors.transparent,
              );
            },
          ),
          if (p.discountPercent > 0)
            PositionedDirectional(
              top: 16,
              start: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${p.discountPercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            bottom: 16,
            end: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn(
    BuildContext context,
    Product p,
    ProductsViewModel productsVm,
    WishlistViewModel wishlistVm,
    CartViewModel cartVm,
    double availableWidth,
  ) {
    final featureCols = availableWidth < 340 ? 2 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          context.l10n.productName(p.id, p.name),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: context.textPrimaryColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),

        // Rating & Stock Row
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 18, color: AppColors.ratingStar),
                const SizedBox(width: 4),
                Text(
                  p.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${p.reviewCount} ${context.tr('reviews')})',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 14, color: context.borderColor),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  p.inStock
                      ? context.tr('in_stock')
                      : context.tr('out_of_stock'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price
        ProductPriceView(
          price: p.price,
          originalPrice: p.originalPrice,
          priceStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: context.themeAccent,
          ),
          originalPriceStyle: const TextStyle(
            fontSize: 18,
            decoration: TextDecoration.lineThrough,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 14),

        // Description
        Text(
          p.description,
          style: TextStyle(
            fontSize: 14,
            color: context.textSecondaryColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Feature Tiles (Adaptive 2 or 4 columns)
        if (p.features.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: featureCols,
              childAspectRatio: featureCols == 2 ? 1.5 : 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: p.features.length > 4 ? 4 : p.features.length,
            itemBuilder: (context, index) {
              final f = p.features[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor, width: 0.8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getFeatureIcon(f.iconKey),
                      size: 22,
                      color: context.themeAccent,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      f.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],

        // Colors Variant Selector (if any)
        if (p.colors.isNotEmpty) ...[
          Text(
            'Color / Finish',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.colors.map((colorName) {
              final isSelected = _selectedColor == colorName;
              return ChoiceChip(
                label: Text(colorName),
                selected: isSelected,
                selectedColor: context.mintBg,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? (context.themeAccent)
                      : context.textPrimaryColor,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedColor = colorName);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Compare Products Shortcut
        GestureDetector(
          onTap: () {
            productsVm.addToCompare(p);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CompareProductsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.mintLightBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.isDarkMode
                    ? AppColors.darkBorder
                    : AppColors.mintDark,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: context.themeAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr('compare_with_other'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.themeAccent,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Expandable Specifications
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            context.tr('product_specs'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: p.specifications.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const Divider(height: 1),

        // Expandable Delivery & Returns
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: Icon(
            Icons.local_shipping_outlined,
            color: context.themeAccent,
          ),
          title: Text(
            context.tr('delivery_returns'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: p.deliveryInfo.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const Divider(height: 1),

        // Customer Reviews Entry
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.rate_review_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            '${context.tr('customer_reviews')} (${p.reviewCount})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductReviewsScreen(product: p),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Similar Products Carousel
        SectionHeader(
          title: context.tr('similar_products'),
          onActionTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchResultsScreen(
                  initialCategory: p.categoryId,
                  categoryTitle: context.l10nRead.similarInMsg(
                    context.l10nRead.categoryName(p.categoryId, p.categoryName),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        FutureBuilder<List<Product>>(
          future: productsVm.getSimilarProducts(p.categoryId, p.id),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            if (list.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final sim = list[index];
                  return SizedBox(
                    width: 150,
                    child: ProductGridCard(
                      product: sim,
                      isInWishlist: wishlistVm.isInWishlist(sim.id),
                      onWishlistTap: () => wishlistVm.toggleWishlist(sim),
                      onAddToCart: () => cartVm.addToCart(sim),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartVm = context.read<CartViewModel>();
    final wishlistVm = context.watch<WishlistViewModel>();
    final productsVm = context.watch<ProductsViewModel>();
    final isInWishlist = wishlistVm.isInWishlist(p.id);

    final images = p.images.isNotEmpty ? p.images : [''];

    return AddToCartOverlayScope(
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Builder(
              builder: (buttonContext) => IconButton(
                tooltip: context.isArabic ? 'مشاركة المنتج' : 'Share product',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _shareProduct(buttonContext, p),
              ),
            ),
            IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist
                    ? AppColors.primary
                    : context.textPrimaryColor,
              ),
              onPressed: () {
                wishlistVm.toggleWishlist(p);
              },
            ),
            const CartAppBarButton(),
            const SizedBox(width: 8),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final hPad = ResponsiveLayout.horizontalPadding(
              constraints.maxWidth,
            );
            final galleryHeight = isWide
                ? (constraints.maxHeight * 0.65).clamp(300.0, 440.0)
                : (constraints.maxHeight * 0.38).clamp(220.0, 320.0);

            if (isWide) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(hPad),
                child: ResponsiveConstrainedBox(
                  maxWidth: 1160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildGallery(context, p, images, galleryHeight),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        flex: 6,
                        child: _buildDetailsColumn(
                          context,
                          p,
                          productsVm,
                          wishlistVm,
                          cartVm,
                          constraints.maxWidth * 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: ResponsiveConstrainedBox(
                maxWidth: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGallery(context, p, images, galleryHeight),
                    const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: _buildDetailsColumn(
                        context,
                        p,
                        productsVm,
                        wishlistVm,
                        cartVm,
                        constraints.maxWidth - (hPad * 2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.isDarkMode ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDarkMode ? 0.25 : 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: ResponsiveConstrainedBox(
              maxWidth: 1160,
              child: Row(
                children: [
                  // Quantity Stepper (Mockup Match: - 1 + in rounded pill)
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: context.surfaceBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                        ),
                        Text(
                          '$_quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            setState(() => _quantity++);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Add to Cart Button or Sign In Button if Guest
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: Builder(
                        builder: (ctx) {
                          final auth = ctx.watch<AuthViewModel>();
                          if (!auth.isAuthenticated) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SignInScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.actionColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      ctx.l10n.tr('sign_in_to_see_price_btn'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ElevatedButton(
                            key: _addButtonKey,
                            onPressed: p.inStock
                                ? () {
                                    AddToCartOverlayScope.maybeOf(
                                      ctx,
                                    )?.flyToCart(
                                      sourceKey: _addButtonKey,
                                      imageUrl: p.images.isNotEmpty
                                          ? p.images.first
                                          : null,
                                    );
                                    cartVm.addToCart(
                                      p,
                                      quantity: _quantity,
                                      selectedColor: _selectedColor,
                                    );
                                    final l10nR = context.l10nRead;
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10nR.addedQtyToCartMsg(
                                              _quantity,
                                              l10nR.productName(p.id, p.name),
                                            ),
                                          ),
                                          backgroundColor: context.actionColor,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                          persist: false,
                                          action: SnackBarAction(
                                            label: l10nR.tr('view_cart'),
                                            textColor: Colors.white,
                                            disabledTextColor: Colors.white70,
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).clearSnackBars();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CartScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.actionColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    ctx.l10n.tr('add_to_cart'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
