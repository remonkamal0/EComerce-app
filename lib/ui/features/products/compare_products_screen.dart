import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/ui/core_widgets/add_to_cart_animation.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/section_header.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/core_widgets/product_price_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import '../auth/sign_in_screen.dart';
import 'product_details_screen.dart';

class CompareProductsScreen extends StatefulWidget {
  const CompareProductsScreen({super.key});

  @override
  State<CompareProductsScreen> createState() => _CompareProductsScreenState();
}

class _CompareProductsScreenState extends State<CompareProductsScreen> {
  final Map<String, GlobalKey> _productImageKeys = {};

  GlobalKey _imageKeyFor(String productId) =>
      _productImageKeys.putIfAbsent(productId, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final cartVm = context.read<CartViewModel>();
    final compareList = productsVm.compareProducts;

    return AddToCartOverlayScope(
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
          title: Text(context.tr('compare_products')),
          actions: [
            if (compareList.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Comparison?'),
                      content: const Text('Do you want to remove all products from comparison?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            productsVm.clearComparison();
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const CartAppBarButton(),
            const SizedBox(width: 8),
          ],
        ),
      body: compareList.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.mintBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.compare_arrows,
                      size: 40,
                      color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('no_compare_title'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('no_compare_msg'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ResponsiveConstrainedBox(
                maxWidth: ResponsiveLayout.maxReadableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Highlight Differences Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        context.tr('highlight_differences'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      Switch(
                        activeThumbColor: AppColors.primary,
                        value: productsVm.highlightDifferences,
                        onChanged: (_) => productsVm.toggleHighlightDifferences(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Side-by-Side Product Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...compareList.map((product) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.surfaceBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.borderColor, width: 1),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 110,
                                      child: ApplianceImage(
                                        key: _imageKeyFor(product.id),
                                        imageUrl: product.images.isNotEmpty ? product.images.first : '',
                                        fit: BoxFit.contain,
                                        borderRadius: 12,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      context.l10n.productName(product.id, product.name),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ProductPriceView(
                                      price: product.price,
                                      isCompact: true,
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (ctx) {
                                        final auth = ctx.watch<AuthViewModel>();
                                        return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            minimumSize: const Size(double.infinity, 36),
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (!auth.isAuthenticated) {
                                              Navigator.of(ctx).push(
                                                MaterialPageRoute(builder: (_) => const SignInScreen()),
                                              );
                                              return;
                                            }
                                            AddToCartOverlayScope.maybeOf(ctx)?.flyToCart(
                                              sourceKey: _imageKeyFor(product.id),
                                              imageUrl: product.images.isNotEmpty
                                                  ? product.images.first
                                                  : null,
                                            );
                                            cartVm.addToCart(product);
                                            final l10nR = ctx.l10nRead;
                                            ScaffoldMessenger.of(context)
                                              ..clearSnackBars()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(l10nR.addedToCartMsg(l10nR.productName(product.id, product.name))),
                                                  backgroundColor: AppColors.primary,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                          },
                                          child: Text(
                                            auth.isAuthenticated ? ctx.l10n.tr('add_to_cart') : ctx.l10n.tr('sign_in_for_price'),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => productsVm.removeFromCompare(product.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: context.cardBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close, size: 14, color: context.textSecondaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (compareList.length < 2)
                        Expanded(
                          child: Container(
                            height: 220,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: context.surfaceBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.borderColor, width: 1, style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.add),
                                label: Text(context.tr('add_product')),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Attribute Rows (Mockup Match: Price, Capacity, Energy Rating, No Frost, Warranty, Dimensions)
                  _buildComparisonTable(context, compareList, productsVm.highlightDifferences),
                  const SizedBox(height: 20),

                  // Mint Action: "See More Details >"
                  GestureDetector(
                    onTap: () {
                      if (compareList.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: compareList.first),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.mintBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.balance,
                            color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('see_more_details'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Similar Products section (Mockup Match: Haier, Toshiba, Beko Refrigerator)
                  SectionHeader(
                    title: context.tr('similar_products'),
                    onActionTap: () {},
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSimilarMiniCard(
                          context,
                          'Haier Refrigerator',
                          '\$549',
                          'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400&auto=format&fit=crop&q=80',
                        ),
                        _buildSimilarMiniCard(
                          context,
                          'Toshiba Refrigerator',
                          '\$569',
                          'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=400&auto=format&fit=crop&q=80',
                        ),
                        _buildSimilarMiniCard(
                          context,
                          'Beko Refrigerator',
                          '\$579',
                          'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400&auto=format&fit=crop&q=80',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
              ),
            ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context, List<Product> list, bool highlightDiff) {
    final auth = context.watch<AuthViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildRow(
            context,
            context.tr('price'),
            list.map((p) => auth.isAuthenticated ? '\$${p.price.toInt()}' : context.tr('sign_in_for_price')).toList(),
            highlightDiff,
          ),
          const Divider(height: 1),
          _buildRow(context, context.tr('capacity'), list.map((p) => p.capacity.isNotEmpty ? p.capacity : '600 L').toList(), highlightDiff),
          const Divider(height: 1),
          _buildRow(context, context.tr('energy_rating'), list.map((p) => p.energyRating).toList(), highlightDiff),
          const Divider(height: 1),
          _buildRow(context, context.tr('no_frost'), list.map((p) => p.hasNoFrost ? 'Yes' : context.tr('no')).toList(), highlightDiff, isIcon: true),
          const Divider(height: 1),
          _buildRow(context, context.tr('warranty'), list.map((p) => p.warranty).toList(), highlightDiff),
          const Divider(height: 1),
          _buildRow(context, context.tr('dimensions'), list.map((p) => p.dimensions.isNotEmpty ? p.dimensions : '70 x 72 x 180 cm').toList(), highlightDiff),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, List<String> values, bool highlightDiff, {bool isIcon = false}) {
    final bool isDiff = values.toSet().length > 1;
    final rowBg = (highlightDiff && isDiff) ? context.mintLightBg : Colors.transparent;
    final accent = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Container(
      color: rowBg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.textSecondaryColor,
              ),
            ),
          ),
          ...values.map((v) {
            return Expanded(
              flex: 4,
              child: Center(
                child: isIcon && v == 'Yes'
                    ? Icon(Icons.check_circle, color: accent, size: 20)
                    : Text(
                        v,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: (highlightDiff && isDiff) ? accent : context.textPrimaryColor,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimilarMiniCard(BuildContext context, String name, String price, String img) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ApplianceImage(
              imageUrl: img,
              borderRadius: 8,
              fit: BoxFit.contain,
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          Builder(
            builder: (ctx) {
              final auth = ctx.watch<AuthViewModel>();
              return Text(
                auth.isAuthenticated ? price : ctx.l10n.tr('sign_in_for_price'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
              );
            },
          ),
        ],
      ),
    );
  }
}



