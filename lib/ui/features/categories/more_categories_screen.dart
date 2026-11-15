import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/ui/core_widgets/category_card.dart';
import 'package:homeplus/ui/core_widgets/promo_banner.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/section_header.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../products/search_results_screen.dart';

class MoreCategoriesScreen extends StatelessWidget {
  const MoreCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final allMore = productsVm.moreCategories;

    final l10n = context.l10n;
    final electronics = allMore.where((c) => c.group == 'Electronics').toList();
    final essentials = allMore.where((c) => c.group == 'Home Essentials').toList();
    final living = allMore.where((c) => c.group == 'Home & Living').toList();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.tr('more_categories')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = ResponsiveLayout.horizontalPadding(constraints.maxWidth);
          final catCols = ResponsiveLayout.categoryGridColumns(constraints.maxWidth);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
            child: ResponsiveConstrainedBox(
              maxWidth: 1100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group 1: Electronics
                  SectionHeader(
                    title: l10n.tr('electronics'),
                    actionText: l10n.tr('see_all'),
                    onActionTap: () {
                      productsVm.selectCategory('tv_electronics');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchResultsScreen(
                            initialCategory: 'tv_electronics',
                            categoryTitle: context.l10nRead.tr('electronics'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildCategoryRow(context, electronics, catCols),
                  const SizedBox(height: 20),

                  // Group 2: Home Essentials
                  SectionHeader(
                    title: l10n.tr('home_essentials'),
                    actionText: l10n.tr('see_all'),
                    onActionTap: () {
                      productsVm.selectCategory('kitchen_appliances');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchResultsScreen(
                            initialCategory: 'kitchen_appliances',
                            categoryTitle: context.l10nRead.tr('home_essentials'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildCategoryRow(context, essentials, catCols),
                  const SizedBox(height: 20),

                  // Group 3: Home & Living
                  SectionHeader(
                    title: l10n.tr('home_living'),
                    actionText: l10n.tr('see_all'),
                    onActionTap: () {
                      productsVm.selectCategory('home_supplies');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchResultsScreen(
                            initialCategory: 'home_supplies',
                            categoryTitle: context.l10nRead.tr('home_living'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildCategoryRow(context, living, catCols),
                  const SizedBox(height: 24),

                  // Mint Banner: "Better Home Better Life - Shop Now ->" (Mockup Match)
                  PromoBanner(
                    title: l10n.tr('banner_better_home'),
                    subtitle: l10n.tr('banner_better_home_sub'),
                    buttonText: l10n.tr('shop_now'),
                    imageUrl: 'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=500&auto=format&fit=crop&q=80',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchResultsScreen(
                            categoryTitle: context.l10nRead.tr('home_living_collection'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, List<dynamic> categories, int catCols) {
    final productsVm = context.read<ProductsViewModel>();

    return StaggeredListLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: catCols,
          childAspectRatio: 0.88,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return StaggeredGridItem(
            index: index,
            columnCount: catCols,
            child: CategoryCompactCard(
              category: cat,
              onTap: () {
                productsVm.selectCategory(cat.id);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SearchResultsScreen(
                      initialCategory: cat.id,
                      categoryTitle: context.l10nRead.categoryName(cat.id, cat.name),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


