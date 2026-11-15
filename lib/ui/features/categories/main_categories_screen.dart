import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/category_card.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import '../products/search_results_screen.dart';
import 'more_categories_screen.dart';

class MainCategoriesScreen extends StatefulWidget {
  const MainCategoriesScreen({super.key});

  @override
  State<MainCategoriesScreen> createState() => _MainCategoriesScreenState();
}

class _MainCategoriesScreenState extends State<MainCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _categoryFilter = '';
  bool _showSearchBar = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategoryResults(
    BuildContext context,
    String categoryId,
    String title,
  ) {
    context.read<ProductsViewModel>().selectCategory(categoryId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          initialCategory: categoryId,
          categoryTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final l10n = context.l10n;
    final isDark = context.isDarkMode;
    final accentPrimary = context.themeAccent;

    final allCats = productsVm.categories;
    final filteredCats = allCats.where((c) {
      if (_categoryFilter.trim().isEmpty) return true;
      final q = _categoryFilter.toLowerCase().trim();
      return c.name.toLowerCase().contains(q) ||
          l10n.categoryName(c.id, c.name).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = ResponsiveLayout.horizontalPadding(
              constraints.maxWidth,
            );
            final catCols = ResponsiveLayout.categoryGridColumns(
              constraints.maxWidth,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 28),
              child: ResponsiveConstrainedBox(
                maxWidth: 1100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Large Title + Circular Elevated Search Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.tr('categories_title'),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimaryColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _HeaderCircleButton(
                              icon: _showSearchBar
                                  ? Icons.close_rounded
                                  : Icons.search_rounded,
                              onTap: () {
                                setState(() {
                                  _showSearchBar = !_showSearchBar;
                                  if (!_showSearchBar) {
                                    _searchController.clear();
                                    _categoryFilter = '';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Optional Expandable Category Filter Bar when Search Button is tapped
                    AnimatedSize(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: _showSearchBar
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: context.cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: accentPrimary.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: accentPrimary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        autofocus: true,
                                        onChanged: (val) => setState(
                                          () => _categoryFilter = val,
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty) {
                                            productsVm.setSearchQuery(
                                              val.trim(),
                                            );
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const SearchResultsScreen(),
                                              ),
                                            );
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: l10n.tr(
                                            'search_categories_hint',
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          filled: false,
                                        ),
                                      ),
                                    ),
                                    if (_categoryFilter.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          setState(() => _categoryFilter = '');
                                        },
                                        child: Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // Hero Promotional Card (Mockup Style in HomePlus Emerald & Mint)
                    _CatalogHeroBanner(
                      title: l10n.tr('catalog_hero_title'),
                      onTap: () {
                        productsVm.selectCategory('tv_electronics');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SearchResultsScreen(
                              initialCategory: 'tv_electronics',
                              categoryTitle: context.l10nRead.tr(
                                'tv_electronics_cat',
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Rounded Catalog Category Grid (Adaptive columns)
                    StaggeredListLimiter(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: catCols,
                          mainAxisExtent:
                              100 +
                              MediaQuery.textScalerOf(context).scale(13) * 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredCats.length,
                        itemBuilder: (context, index) {
                          final cat = filteredCats[index];
                          return StaggeredGridItem(
                            index: index,
                            columnCount: catCols,
                            child: CategoryCatalogCard(
                              category: cat,
                              onTap: () => _openCategoryResults(
                                context,
                                cat.id,
                                context.l10nRead.categoryName(cat.id, cat.name),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtle "See All" Groups link to MoreCategoriesScreen
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MoreCategoriesScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.grid_view_rounded,
                          size: 17,
                          color: accentPrimary,
                        ),
                        label: Text(
                          l10n.tr('more_categories'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accentPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.cardBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.7),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Icon(icon, size: 22, color: context.textPrimaryColor),
        ),
      ),
    );
  }
}

class _CatalogHeroBanner extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CatalogHeroBanner({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final accentPrimary = context.themeAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: isDark
                ? [AppColors.darkMint, AppColors.darkSurface]
                : [context.mintLightBg, context.mintBg],
          ),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.mintDark.withValues(alpha: 0.65),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Soft decorative horizon curve & glow
              PositionedDirectional(
                end: -18,
                top: -22,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.14 : 0.08,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimaryColor,
                              height: 1.25,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 34,
                            height: 4,
                            decoration: BoxDecoration(
                              color: accentPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentPrimary.withValues(
                                  alpha: isDark ? 0.22 : 0.14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.actionColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.actionColor.withValues(
                                      alpha: 0.28,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_shipping_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            PositionedDirectional(
                              bottom: 4,
                              start: 2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: context.cardBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
                                ),
                                child: Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: accentPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
