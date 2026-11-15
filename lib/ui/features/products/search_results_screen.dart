import 'package:flutter/material.dart';
import 'package:homeplus/ui/core_widgets/add_to_cart_animation.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/product_card.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'search_filters_sheet.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? initialCategory;
  final String? categoryTitle;

  const SearchResultsScreen({
    super.key,
    this.initialCategory,
    this.categoryTitle,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProductsViewModel>();
      if (widget.initialCategory != null) {
        vm.selectCategory(widget.initialCategory);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortSheet(BuildContext context) {
    final vm = context.read<ProductsViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('sort_by'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSortOption(context, vm, 'recommended', context.tr('sort_recommended')),
                _buildSortOption(context, vm, 'price_asc', context.tr('sort_price_asc')),
                _buildSortOption(context, vm, 'price_desc', context.tr('sort_price_desc')),
                _buildSortOption(context, vm, 'rating', context.tr('sort_rating')),
                _buildSortOption(context, vm, 'newest', context.tr('sort_newest')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    ProductsViewModel vm,
    String value,
    String label,
  ) {
    final isSelected = vm.sortBy == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? (context.isDarkMode ? AppColors.primaryLight : AppColors.primary)
              : context.textPrimaryColor,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
            )
          : null,
      onTap: () {
        vm.setSortBy(value);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final cartVm = context.read<CartViewModel>();
    final wishlistVm = context.watch<WishlistViewModel>();

    final results = productsVm.searchResults;
    final chips = productsVm.activeFilterChips;

    return AddToCartOverlayScope(
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: context.surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: context.textSecondaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => productsVm.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: context.tr('search_products_hint'),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      productsVm.setSearchQuery('');
                    },
                    child: Icon(Icons.clear, size: 18, color: context.textSecondaryColor),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          // Filter Icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchFiltersSheet()),
                  );
                },
              ),
              if (productsVm.activeFiltersCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${productsVm.activeFiltersCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const CartAppBarButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applied Filter Chips (Mockup Match)
          if (chips.isNotEmpty) ...[
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = chips[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chip,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => productsVm.removeFilterChip(chip),
                          child: Icon(Icons.close, size: 14, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],

          // Control Bar: Count + Sort Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.productsFoundMsg(results.length),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSortSheet(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.swap_vert,
                        size: 18,
                        color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('sort'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Results Grid or Empty View
          Expanded(
            child: results.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off,
                    title: context.tr('no_products_found'),
                    message: context.tr('no_products_msg_long'),
                    buttonText: context.tr('reset_filters'),
                    onButtonPressed: () {
                      _searchController.clear();
                      productsVm.resetFilters();
                    },
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final effectiveWidth = constraints.maxWidth
                          .clamp(0.0, ResponsiveLayout.maxContentWidth);
                      final hPad = ResponsiveLayout.horizontalPadding(effectiveWidth);
                      final cols = ResponsiveLayout.productGridColumns(effectiveWidth);
                      final ratio = ResponsiveLayout.productCardAspectRatio(effectiveWidth);

                      return ResponsiveConstrainedBox(
                        child: StaggeredListLimiter(
                          child: GridView.builder(
                            padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              childAspectRatio: ratio,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final product = results[index];
                              final isInWishlist = wishlistVm.isInWishlist(product.id);

                              return StaggeredGridItem(
                                index: index,
                                columnCount: cols,
                                child: ProductGridCard(
                                  product: product,
                                  isInWishlist: isInWishlist,
                                  onWishlistTap: () {
                                    wishlistVm.toggleWishlist(product);
                                  },
                                  onAddToCart: () {
                                    cartVm.addToCart(product);
                                    final l10nR = context.l10nRead;
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 1),
                                          content: Text(l10nR.addedToCartMsg(l10nR.productName(product.id, product.name))),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }
}


