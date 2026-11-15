import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/app_logo.dart';
import 'package:homeplus/ui/core_widgets/promo_banner.dart';
import 'package:homeplus/ui/core_widgets/section_header.dart';
import 'package:homeplus/ui/core_widgets/category_card.dart';
import 'package:homeplus/ui/core_widgets/product_card.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';
import '../products/search_results_screen.dart';
import '../categories/main_categories_screen.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notifications/notifications_screen.dart';
import 'featured_offers_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  List<Map<String, String>> _buildBanners(AppLocalizations l10n) => [
    {
      'title': l10n.tr('banner_upgrade_title'),
      'subtitle': l10n.tr('banner_upgrade_sub_2'),
      'image': 'assets/home-banners/kitchen.jpg',
    },
    {
      'title': l10n.tr('banner_big_deals_off'),
      'subtitle': l10n.tr('banner_brands_sub'),
      'image': 'assets/home-banners/television.jpg',
    },
    {
      'title': l10n.tr('banner_cooling_title'),
      'subtitle': l10n.tr('banner_cooling_sub'),
      'image': 'assets/home-banners/cooling.jpg',
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final cartVm = context.watch<CartViewModel>();
    final wishlistVm = context.watch<WishlistViewModel>();
    final supportVm = context.watch<SupportViewModel>();
    final l10n = context.l10n;
    final banners = _buildBanners(l10n);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: const AppLogo(
          iconSize: 34,
          showTagline: false,
          isHorizontal: true,
        ),
        actions: [
          _buildHeaderActionIcon(
            context,
            icon: Icons.shopping_cart_outlined,
            badgeCount: cartVm.itemCount,
            onPressed: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(2);
              } else {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              }
            },
          ),
          _buildHeaderActionIcon(
            context,
            icon: Icons.favorite_border,
            badgeCount: wishlistVm.itemCount,
            onPressed: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(3);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              }
            },
          ),
          _buildHeaderActionIcon(
            context,
            icon: Icons.notifications_outlined,
            showDot: supportVm.unreadNotificationsCount > 0,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productsVm.loadInitialData(),
        color: AppColors.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final effectiveWidth = constraints.maxWidth.clamp(
              0.0,
              ResponsiveLayout.maxContentWidth,
            );
            final hPad = ResponsiveLayout.horizontalPadding(effectiveWidth);
            final textScaler = MediaQuery.textScalerOf(context);
            final bannerHeight =
                ((effectiveWidth - 2 * hPad) * 0.32).clamp(156.0, 190.0) +
                (textScaler.scale(16) - 16) * 4;
            final productCols = ResponsiveLayout.productGridColumns(
              effectiveWidth,
            );
            final productAspect = ResponsiveLayout.productCardAspectRatio(
              effectiveWidth,
            );
            final offerCols = ResponsiveLayout.cardListColumns(effectiveWidth);
            final contentWidth = effectiveWidth - (hPad * 2);
            final offerItemWidth = offerCols > 1
                ? (contentWidth - (offerCols - 1) * 12) / offerCols
                : contentWidth;
            final recommendedCount = productCols >= 4
                ? (productsVm.allProducts.length > productCols * 2
                      ? productCols * 2
                      : productsVm.allProducts.length)
                : (productsVm.allProducts.length > 6
                      ? 6
                      : productsVm.allProducts.length);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: ResponsiveConstrainedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Search Bar
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.surfaceBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: context.textSecondaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.tr('search_products_hint'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Promotional Banner Carousel
                    SizedBox(
                      height: bannerHeight,
                      child: PageView.builder(
                        controller: _bannerController,
                        itemCount: banners.length,
                        onPageChanged: (idx) =>
                            setState(() => _currentBannerIndex = idx),
                        itemBuilder: (context, index) {
                          final b = banners[index];
                          return PromoBanner(
                            title: b['title']!,
                            subtitle: b['subtitle'],
                            imageUrl: b['image'],
                            buttonText: l10n.tr('shop_now'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FeaturedOffersScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Banner Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(banners.length, (index) {
                        final isSelected = index == _currentBannerIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isSelected ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.themeAccent
                                : context.borderColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Categories Section Header
                    SectionHeader(
                      title: l10n.tr('categories'),
                      actionText: l10n.tr('see_all'),
                      onActionTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1); // Go to Categories tab
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MainCategoriesScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),

                    // Categories Horizontal List
                    SizedBox(
                      height: 78 + textScaler.scale(12) * 2.5,
                      child: StaggeredListLimiter(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: productsVm.primaryCategories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final cat = productsVm.primaryCategories[index];
                            return StaggeredListItem(
                              index: index,
                              verticalOffset: 0,
                              horizontalOffset: 36,
                              child: CategoryHomeShortcut(
                                category: cat,
                                onTap: () {
                                  productsVm.selectCategory(cat.id);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SearchResultsScreen(
                                        initialCategory: cat.id,
                                        categoryTitle: context.l10nRead
                                            .categoryName(cat.id, cat.name),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Featured Offers Section Header
                    SectionHeader(
                      title: l10n.tr('featured_offers'),
                      actionText: l10n.tr('see_all'),
                      onActionTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FeaturedOffersScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Featured Offers Cards List (Adaptive 1-3 columns)
                    StaggeredListLimiter(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 0,
                        children: productsVm.featuredOffers
                            .take(offerCols > 1 ? 4 : 3)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              return SizedBox(
                                width: offerItemWidth,
                                child: StaggeredListItem(
                                  index: entry.key,
                                  child: ProductOfferCard(product: entry.value),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Best Sellers / Recommended Grid
                    SectionHeader(
                      title: l10n.tr('recommended_for_you'),
                      actionText: l10n.tr('see_all'),
                      onActionTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    StaggeredListLimiter(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: productCols,
                          childAspectRatio: productAspect,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: recommendedCount,
                        itemBuilder: (context, index) {
                          final product = productsVm.allProducts[index];
                          final isInWishlist = wishlistVm.isInWishlist(
                            product.id,
                          );

                          return StaggeredGridItem(
                            index: index,
                            columnCount: productCols,
                            child: ProductGridCard(
                              product: product,
                              isInWishlist: isInWishlist,
                              onWishlistTap: () {
                                wishlistVm.toggleWishlist(product);
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(
                                        context.l10nRead.tr(
                                          isInWishlist
                                              ? 'removed_from_wishlist'
                                              : 'added_to_wishlist',
                                        ),
                                      ),
                                    ),
                                  );
                              },
                              onAddToCart: () {
                                cartVm.addToCart(product);
                                final l10nR = context.l10nRead;
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(
                                        l10nR.addedToCartMsg(
                                          l10nR.productName(
                                            product.id,
                                            product.name,
                                          ),
                                        ),
                                      ),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderActionIcon(
    BuildContext context, {
    required IconData icon,
    int badgeCount = 0,
    bool showDot = false,
    required VoidCallback onPressed,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
          padding: const EdgeInsets.all(8),
          icon: Icon(icon, size: 24, color: context.textPrimaryColor),
          onPressed: onPressed,
        ),
        if (badgeCount > 0)
          PositionedDirectional(
            top: 4,
            end: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          )
        else if (showDot)
          PositionedDirectional(
            top: 9,
            end: 10,
            child: IgnorePointer(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
