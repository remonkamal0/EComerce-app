import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import '../products/product_details_screen.dart';

class _UserReviewEntry {
  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final double rating;
  final String dateLabel;
  final String comment;

  const _UserReviewEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.rating,
    required this.dateLabel,
    required this.comment,
  });
}

class MyReviewsScreen extends StatefulWidget {
  final Product? initialProduct;

  const MyReviewsScreen({super.key, this.initialProduct});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 4;
  String? _selectedProductId;

  late List<_UserReviewEntry> _recentReviews;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.initialProduct?.id;
    _recentReviews = [
      const _UserReviewEntry(
        id: 'rev_user_1',
        productId: 'p_fridge_samsung_600',
        productName: 'Samsung Double Door Refrigerator',
        imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=500&auto=format&fit=crop&q=80',
        rating: 5.0,
        dateLabel: 'Apr 25, 2026',
        comment: 'Outstanding cooling performance and exceptionally quiet delivery!',
      ),
      const _UserReviewEntry(
        id: 'rev_user_2',
        productId: 'p_washer_lg_9kg',
        productName: 'LG Front Load Washing Machine',
        imageUrl: 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500&auto=format&fit=crop&q=80',
        rating: 5.0,
        dateLabel: 'Apr 12, 2026',
        comment: 'TurboWash cleans super fast with zero vibration during spin.',
      ),
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Product _resolveTargetProduct(ProductsViewModel productsVm) {
    if (widget.initialProduct != null && _selectedProductId == widget.initialProduct!.id) {
      return widget.initialProduct!;
    }
    if (productsVm.allProducts.isEmpty) {
      return const Product(
        id: 'p_fridge_samsung_600',
        name: 'Samsung Double Door Refrigerator',
        brand: 'Samsung',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 799,
        originalPrice: 899,
        rating: 4.9,
        reviewCount: 320,
        description: '',
        images: ['https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=500&auto=format&fit=crop&q=80'],
      );
    }
    if (_selectedProductId != null) {
      return productsVm.allProducts.firstWhere(
        (p) => p.id == _selectedProductId,
        orElse: () => productsVm.allProducts.first,
      );
    }
    return productsVm.allProducts.first;
  }

  String _formatTodayLabel() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _submitReview() {
    final productsVm = context.read<ProductsViewModel>();
    final authVm = context.read<AuthViewModel>();
    final targetProduct = _resolveTargetProduct(productsVm);
    final l10nR = context.l10nRead;
    final comment = _commentController.text.trim();
    final rating = _selectedRating.toDouble();

    final newReview = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: targetProduct.id,
      productName: targetProduct.name,
      userName: authVm.currentUser?.name ?? 'HomePlus Shopper',
      rating: rating,
      date: DateTime.now(),
      comment: comment.isEmpty ? l10nR.tr('review_submitted_msg') : comment,
      isVerifiedPurchase: true,
    );

    productsVm.addReview(newReview);

    setState(() {
      _recentReviews.insert(
        0,
        _UserReviewEntry(
          id: newReview.id,
          productId: targetProduct.id,
          productName: targetProduct.name,
          imageUrl: targetProduct.images.isNotEmpty ? targetProduct.images.first : '',
          rating: rating,
          dateLabel: _formatTodayLabel(),
          comment: comment.isEmpty ? l10nR.tr('review_submitted_msg') : comment,
        ),
      );
      _commentController.clear();
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10nR.tr('review_submitted_msg')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _openProductPicker(List<Product> products) {
    if (products.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        final l10n = sheetCtx.l10n;
        final accentPrimary = sheetCtx.isDarkMode ? AppColors.primaryLight : AppColors.primary;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetCtx.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.tr('review_for'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: sheetCtx.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, idx) {
                    final item = products[idx];
                    final isSelected = item.id == _resolveTargetProduct(context.read<ProductsViewModel>()).id;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected ? accentPrimary : sheetCtx.borderColor,
                        ),
                      ),
                      tileColor: isSelected ? sheetCtx.mintLightBg : sheetCtx.surfaceBg,
                      leading: SizedBox(
                        width: 44,
                        height: 44,
                        child: ApplianceImage(
                          imageUrl: item.images.isNotEmpty ? item.images.first : '',
                          borderRadius: 10,
                          fit: BoxFit.contain,
                        ),
                      ),
                      title: Text(
                        l10n.productName(item.id, item.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: sheetCtx.textPrimaryColor,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: accentPrimary)
                          : null,
                      onTap: () {
                        setState(() => _selectedProductId = item.id);
                        Navigator.of(sheetCtx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();
    final l10n = context.l10n;
    final isDark = context.isDarkMode;
    final accentPrimary = isDark ? AppColors.primaryLight : AppColors.primary;
    final targetProduct = _resolveTargetProduct(productsVm);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              onPressed: _submitReview,
              child: Text(
                l10n.tr('submit_review'),
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Top-trailing subtle curved mint accent matching the UI mockup
          PositionedDirectional(
            top: -55,
            end: -36,
            child: IgnorePointer(
              child: Container(
                width: 210,
                height: 165,
                decoration: BoxDecoration(
                  color: context.mintBg.withValues(alpha: isDark ? 0.55 : 0.85),
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(140),
                    bottomEnd: Radius.circular(80),
                    topStart: Radius.circular(90),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar Row (Circular Back Button + Centered Bold Title)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: Ink(
                            width: 42,
                            height: 42,
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
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.tr('rating_and_reviews'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Cloud Header + Overlapping Interactive Star Picker Card
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 34),
                              padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
                              decoration: BoxDecoration(
                                color: context.mintLightBg,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: context.mintBg.withValues(alpha: isDark ? 0.8 : 0.9),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (idx) {
                                      final active = (idx + 1) <= _selectedRating;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(
                                          Icons.star_rounded,
                                          size: 28,
                                          color: active
                                              ? accentPrimary
                                              : context.borderColor,
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.tr('how_was_experience'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.tr('feedback_helps_improve'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Floating Interactive 5-Star Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: context.borderColor.withValues(alpha: 0.8),
                                ),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.08),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (idx) {
                                  final value = idx + 1;
                                  final selected = value <= _selectedRating;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedRating = value),
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: AnimatedScale(
                                        scale: selected ? 1.06 : 1.0,
                                        duration: const Duration(milliseconds: 160),
                                        child: Icon(
                                          selected ? Icons.star_rounded : Icons.star_outline_rounded,
                                          size: 36,
                                          color: selected ? accentPrimary : context.textSecondaryColor.withValues(alpha: 0.45),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Compact Product Chip (lets user pick product being rated)
                        GestureDetector(
                          onTap: () => _openProductPicker(productsVm.allProducts),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.surfaceBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: context.borderColor.withValues(alpha: 0.8)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: ApplianceImage(
                                    imageUrl: targetProduct.images.isNotEmpty
                                        ? targetProduct.images.first
                                        : '',
                                    borderRadius: 8,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${l10n.tr('review_for')}: ${l10n.productName(targetProduct.id, targetProduct.name)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: context.textSecondaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // "Add a Review (Optional)" Section
                        Text(
                          l10n.tr('add_review_optional'),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.borderColor),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _commentController,
                                maxLines: 4,
                                maxLength: 500,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: context.textPrimaryColor,
                                  height: 1.4,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.tr('tell_us_experience'),
                                  hintStyle: TextStyle(
                                    color: context.textSecondaryColor.withValues(alpha: 0.75),
                                    fontSize: 13.5,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: Text(
                                  '${_commentController.text.length}/500',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // "Your Recent Reviews" Header
                        Text(
                          l10n.tr('your_recent_reviews'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_recentReviews.isEmpty)
                          EmptyStateView(
                            icon: Icons.rate_review_outlined,
                            title: l10n.tr('no_reviews_yet'),
                            message: l10n.tr('no_reviews_msg'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentReviews.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final rev = _recentReviews[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: context.borderColor.withValues(alpha: 0.85),
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.035),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 66,
                                      height: 66,
                                      child: ApplianceImage(
                                        imageUrl: rev.imageUrl,
                                        borderRadius: 14,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  l10n.productName(rev.productId, rev.productName),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: context.textPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                iconSize: 20,
                                                icon: Icon(
                                                  Icons.more_horiz_rounded,
                                                  color: context.textSecondaryColor,
                                                ),
                                                onSelected: (choice) {
                                                  if (choice == 'view' && productsVm.allProducts.isNotEmpty) {
                                                    final p = productsVm.allProducts.firstWhere(
                                                      (item) => item.id == rev.productId,
                                                      orElse: () => productsVm.allProducts.first,
                                                    );
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => ProductDetailsScreen(product: p),
                                                      ),
                                                    );
                                                  } else if (choice == 'delete') {
                                                    setState(() => _recentReviews.removeAt(index));
                                                  }
                                                },
                                                itemBuilder: (menuCtx) => [
                                                  PopupMenuItem(
                                                    value: 'view',
                                                    child: Text(l10n.tr('view_product')),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      l10n.tr('delete_review'),
                                                      style: const TextStyle(color: AppColors.error),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: List.generate(5, (starIdx) {
                                              final filled = (starIdx + 1) <= rev.rating.round();
                                              return Icon(
                                                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                                size: 16,
                                                color: filled ? accentPrimary : context.borderColor,
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            rev.comment,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: context.textSecondaryColor,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            rev.dateLabel,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
    );
  }
}
