import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/product_card.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import '../products/search_results_screen.dart';

class FeaturedOffersScreen extends StatelessWidget {
  const FeaturedOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final offers = productsVm.featuredOffers;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr('featured_offers')),
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
          final effectiveWidth =
              constraints.maxWidth.clamp(0.0, ResponsiveLayout.maxContentWidth);
          final hPad = ResponsiveLayout.horizontalPadding(effectiveWidth);
          final cols = ResponsiveLayout.cardListColumns(effectiveWidth);
          final contentWidth = effectiveWidth - (hPad * 2);
          final itemWidth = cols > 1
              ? (contentWidth - (cols - 1) * 12) / cols
              : contentWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
            child: ResponsiveConstrainedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('special_offers'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('special_offers_sub'),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Adaptive Offers List/Grid
                  StaggeredListLimiter(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 0,
                      children: offers.asMap().entries.map((entry) {
                        return SizedBox(
                          width: itemWidth,
                          child: StaggeredListItem(
                            index: entry.key,
                            child: ProductOfferCard(
                              product: entry.value,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mint Banner: "Don't Miss Out! Exclusive offers for a limited time >"
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.mintBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.discount_outlined,
                            color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('banner_dont_miss'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('banner_exclusive_limited'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: context.textPrimaryColor,
                          size: 20,
                        ),
                      ],
                    ),
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
}


