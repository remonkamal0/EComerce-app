import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'payment_processing_screen.dart';

class ReviewOrderScreen extends StatelessWidget {
  final Address selectedAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final bool hasInstallation;

  const ReviewOrderScreen({
    super.key,
    required this.selectedAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    this.hasInstallation = false,
  });

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Review Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // 1. Delivery Address Card
            _buildSectionCard(
              context: context,
              title: 'Delivery Address',
              onEdit: () => Navigator.of(context).pop(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAddress.recipientName,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimaryColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedAddress.formattedAddress,
                    style: TextStyle(color: context.textSecondaryColor, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedAddress.phone,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Delivery & Installation Card
            _buildSectionCard(
              context: context,
              title: 'Delivery & Service',
              onEdit: () => Navigator.of(context).pop(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(deliveryMethod, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: context.textPrimaryColor)),
                      Text('\$${cartVm.deliveryFee.toInt()}', style: TextStyle(fontWeight: FontWeight.w700, color: context.textPrimaryColor)),
                    ],
                  ),
                  if (hasInstallation) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Professional Installation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: context.textPrimaryColor)),
                        Text('\$${cartVm.installationFee.toInt()}', style: TextStyle(fontWeight: FontWeight.w700, color: context.textPrimaryColor)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Payment Method Card
            _buildSectionCard(
              context: context,
              title: 'Payment Method',
              onEdit: () => Navigator.of(context).pop(),
              child: Row(
                children: [
                  Icon(Icons.payment, size: 20, color: accentPrimary),
                  const SizedBox(width: 8),
                  Text(
                    paymentMethod,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Order Items
            Text(
              'Order Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 10),

            ...cartVm.items.map((item) {
              final p = item.product;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderColor, width: 0.6),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 55,
                      height: 55,
                      child: ApplianceImage(
                        imageUrl: p.images.isNotEmpty ? p.images.first : '',
                        borderRadius: 10,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.productName(p.id, p.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toInt()}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: accentPrimary),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // 5. Total Cost Summary Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor, width: 1),
              ),
              child: Column(
                children: [
                  _buildPriceRow(context, 'Subtotal', '\$${cartVm.subtotal.toInt()}'),
                  if (cartVm.couponDiscount > 0) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(context, 'Discount (${cartVm.appliedCoupon?.code})', '-\$${cartVm.couponDiscount.toInt()}', isDiscount: true),
                  ],
                  const SizedBox(height: 8),
                  _buildPriceRow(context, 'Delivery Fee', '\$${cartVm.deliveryFee.toInt()}'),
                  if (cartVm.installationFee > 0) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(context, 'Installation Service', '\$${cartVm.installationFee.toInt()}'),
                  ],
                  const SizedBox(height: 12),
                  Divider(height: 1, color: context.dividerColor),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
                      ),
                      Text(
                        '\$${cartVm.total.toInt()}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: accentPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: CustomButton(
              text: 'Place Order',
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentProcessingScreen(
                      selectedAddress: selectedAddress,
                      deliveryMethod: deliveryMethod,
                      paymentMethod: paymentMethod,
                      hasInstallation: hasInstallation,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceBg,
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
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDiscount
                ? (context.isDarkMode ? AppColors.primaryLight : AppColors.primary)
                : context.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}


