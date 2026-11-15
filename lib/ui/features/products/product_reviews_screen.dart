import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';

class ProductReviewsScreen extends StatefulWidget {
  final Product product;

  const ProductReviewsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  void _openWriteReviewSheet(BuildContext context) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
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
                      'Write a Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ctx.l10n.productName(widget.product.id, widget.product.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
                    ),
                    const SizedBox(height: 16),

                    // Star Rating Picker
                    Text('Rate this product:', style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return IconButton(
                          icon: Icon(
                            starValue <= selectedRating ? Icons.star : Icons.star_border,
                            size: 36,
                            color: AppColors.ratingStar,
                          ),
                          onPressed: () {
                            setModalState(() => selectedRating = starValue);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Review text
                    CustomTextField(
                      controller: commentController,
                      hintText: 'Share details of your experience with this appliance...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'Submit Review',
                      onPressed: () {
                        if (commentController.text.trim().isEmpty) return;

                        final auth = context.read<AuthViewModel>();
                        final userName = auth.currentUser?.name ?? 'Verified Buyer';

                        final newRev = Review(
                          id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                          productId: widget.product.id,
                          productName: widget.product.name,
                          userName: userName,
                          rating: selectedRating,
                          date: DateTime.now(),
                          comment: commentController.text.trim(),
                          isVerifiedPurchase: true,
                        );

                        context.read<ProductsViewModel>().addReview(newRev);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you! Your review has been published.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsVm = context.watch<ProductsViewModel>();

    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Customer Reviews'),
      ),
      body: FutureBuilder<List<Review>>(
        future: productsVm.getProductReviews(widget.product.id),
        builder: (context, snapshot) {
          final reviews = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ResponsiveConstrainedBox(
              maxWidth: ResponsiveLayout.maxReadableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Ratings Summary Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Big Score
                      Column(
                        children: [
                          Text(
                            widget.product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return const Icon(Icons.star, size: 16, color: AppColors.ratingStar);
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.product.reviewCount} Reviews',
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Distribution Bars
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar(context, '5', 0.85),
                            _buildRatingBar(context, '4', 0.10),
                            _buildRatingBar(context, '3', 0.03),
                            _buildRatingBar(context, '2', 0.01),
                            _buildRatingBar(context, '1', 0.01),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Write Review CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews (${reviews.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openWriteReviewSheet(context),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Write Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Review Cards
                ...reviews.map((rev) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rev.userName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            if (rev.isVerifiedPurchase)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.mintBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Verified Purchase',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: accentPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < rev.rating ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: AppColors.ratingStar,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${rev.date.day}/${rev.date.month}/${rev.date.year}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rev.comment,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondaryColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              'Helpful (${rev.helpfulCount})',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, String stars, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            stars,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: context.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


