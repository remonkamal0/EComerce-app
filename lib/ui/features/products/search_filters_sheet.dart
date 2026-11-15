import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';

class SearchFiltersSheet extends StatefulWidget {
  const SearchFiltersSheet({super.key});

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  late RangeValues _priceRange;
  late Set<String> _brands;
  String? _category;
  double? _rating;
  bool _inStock = false;
  String? _energy;
  bool _showAllBrands = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProductsViewModel>();
    _priceRange = RangeValues(vm.minPrice, vm.maxPrice);
    _brands = Set.from(vm.selectedBrands);
    _category = vm.selectedCategory;
    _rating = vm.minRating;
    _inStock = vm.inStockOnly;
    _energy = vm.energyEfficiency;
  }

  void _resetLocalFilters() {
    setState(() {
      _priceRange = const RangeValues(100, 1000);
      _brands.clear();
      _category = null;
      _rating = null;
      _inStock = false;
      _energy = null;
    });
  }

  void _apply() {
    final vm = context.read<ProductsViewModel>();
    vm.setPriceRange(_priceRange.start, _priceRange.end);
    vm.resetFilters();
    vm.setPriceRange(_priceRange.start, _priceRange.end);
    for (final b in _brands) {
      vm.toggleBrand(b);
    }
    vm.selectCategory(_category);
    vm.setRating(_rating);
    vm.toggleInStockOnly(_inStock);
    vm.setEnergyEfficiency(_energy);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductsViewModel>();
    final availableBrands = ['Samsung', 'LG', 'Bosch', 'Ariston', 'Daikin', 'Sony', 'Dyson', 'Haier', 'Toshiba', 'Beko'];
    final displayBrands = _showAllBrands ? availableBrands : availableBrands.take(3).toList();

    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(context.tr('filter_products')),
        actions: [
          TextButton(
            onPressed: _resetLocalFilters,
            child: Text(
              context.tr('reset_all'),
              style: TextStyle(
                color: accentPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Range
            Text(
              context.tr('price_range'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: _priceRange,
              min: 50,
              max: 1200,
              divisions: 23,
              activeColor: accentPrimary,
              inactiveColor: context.borderColor,
              onChanged: (vals) => setState(() => _priceRange = vals),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_priceRange.start.toInt()}',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimaryColor),
                  ),
                  Text(
                    '\$${_priceRange.end.toInt()}+',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: context.dividerColor),

            // Brands
            Text(
              context.tr('brand'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ...displayBrands.map((brand) {
              final isChecked = _brands.contains(brand);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: accentPrimary,
                title: Text(
                  brand,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                ),
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _brands.add(brand);
                    } else {
                      _brands.remove(brand);
                    }
                  });
                },
              );
            }),
            GestureDetector(
              onTap: () => setState(() => _showAllBrands = !_showAllBrands),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      _showAllBrands ? context.tr('see_less') : context.tr('see_more'),
                      style: TextStyle(
                        color: accentPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      _showAllBrands ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: accentPrimary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: context.dividerColor),

            // Expandable Category Section
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                context.tr('category'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
              ),
              children: [
                ...vm.categories.map((c) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: accentPrimary,
                    title: Text(context.l10n.categoryName(c.id, c.name), style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
                    value: c.id,
                    groupValue: _category,
                    onChanged: (val) => setState(() => _category = val),
                  );
                }),
              ],
            ),
            Divider(color: context.dividerColor),

            // Rating Filter
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                context.tr('rating'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
              ),
              children: [
                ...[4.5, 4.0, 3.5, 3.0].map((star) {
                  return RadioListTile<double>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: accentPrimary,
                    title: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.ratingStar, size: 18),
                        const SizedBox(width: 6),
                        Text(context.l10n.starAndAboveMsg(star), style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
                      ],
                    ),
                    value: star,
                    groupValue: _rating,
                    onChanged: (val) => setState(() => _rating = val),
                  );
                }),
              ],
            ),
            Divider(color: context.dividerColor),

            // Availability
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: accentPrimary,
              title: Text(
                context.tr('in_stock_only'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
              ),
              value: _inStock,
              onChanged: (val) => setState(() => _inStock = val),
            ),
            Divider(color: context.dividerColor),

            // Energy Efficiency
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                context.tr('energy_efficiency'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
              ),
              children: [
                ...['A+++', 'A++', 'A+', 'A'].map((eff) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: accentPrimary,
                    title: Text(context.l10n.energyClassMsg(eff), style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
                    value: eff,
                    groupValue: _energy,
                    onChanged: (val) => setState(() => _energy = val),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: context.tr('apply_filters'),
            onPressed: _apply,
          ),
        ),
      ),
    );
  }
}



