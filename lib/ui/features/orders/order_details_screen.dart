import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'order_tracking_screen.dart';
import 'return_request_screen.dart';
import '../products/product_reviews_screen.dart';
import '../profile/my_reviews_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  void _showCancelDialog(BuildContext context) {
    String selectedReason = 'Found a better price elsewhere';
    final reasons = [
      'Found a better price elsewhere',
      'Changed my mind / Ordered by mistake',
      'Delivery time is too long',
      'Need to change delivery address',
      'Other reason',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cancel Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please select a reason for cancelling this order:'),
                  const SizedBox(height: 10),
                  ...reasons.map((r) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      title: Text(r, style: const TextStyle(fontSize: 13)),
                      value: r,
                      groupValue: selectedReason,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedReason = val);
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Keep Order'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<OrdersViewModel>().cancelOrder(order.id, selectedReason);
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order has been cancelled successfully.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                  child: const Text('Confirm Cancel', style: TextStyle(color: AppColors.error)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isCancellable = order.status == OrderStatus.confirmed || order.status == OrderStatus.preparing;
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invoice #INV-${order.id}.pdf downloaded to device'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: order.status == OrderStatus.cancelled
                    ? (context.isDarkMode ? AppColors.error.withValues(alpha: 0.16) : AppColors.discountBg)
                    : context.mintLightBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: order.status == OrderStatus.cancelled ? AppColors.error : accentPrimary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    order.status == OrderStatus.cancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
                    color: order.status == OrderStatus.cancelled ? AppColors.error : accentPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${order.statusDisplay}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: order.status == OrderStatus.cancelled ? AppColors.error : accentPrimary,
                          ),
                        ),
                        Text(
                          'Placed on ${order.date.day}/${order.date.month}/${order.date.year}',
                          style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                  if (order.status != OrderStatus.cancelled && order.status != OrderStatus.returned)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(order: order),
                          ),
                        );
                      },
                      child: const Text('Track', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Items
            Text(
              'Purchased Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 10),

            ...order.items.map((item) {
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
                      width: 60,
                      height: 60,
                      child: ApplianceImage(
                        imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '',
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
                            context.l10n.productName(item.product.id, item.product.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Qty: ${item.quantity} • \$${item.product.price.toInt()} each',
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                          if (isDelivered) ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductReviewsScreen(product: item.product),
                                  ),
                                );
                              },
                              child: Text(
                                'Write a Review ★',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accentPrimary,
                                ),
                              ),
                            ),
                          ],
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

            // Delivery Address Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimaryColor)),
                  const SizedBox(height: 6),
                  Text('${order.deliveryAddress.recipientName} (${order.deliveryAddress.phone})', style: TextStyle(fontSize: 13, color: context.textPrimaryColor)),
                  Text(order.deliveryAddress.formattedAddress, style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
                  const SizedBox(height: 4),
                  Text('Method: ${order.deliveryMethod}', style: TextStyle(fontSize: 12, color: accentPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor, width: 0.6),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(context, 'Subtotal', '\$${order.subtotal.toInt()}'),
                  if (order.discount > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(context, 'Discount', '-\$${order.discount.toInt()}', isDiscount: true),
                  ],
                  const SizedBox(height: 6),
                  _buildSummaryRow(context, 'Delivery Fee', '\$${order.deliveryFee.toInt()}'),
                  if (order.installationFee > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(context, 'Installation Fee', '\$${order.installationFee.toInt()}'),
                  ],
                  const SizedBox(height: 10),
                  Divider(color: context.dividerColor),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimaryColor)),
                      Text(
                        '\$${order.total.toInt()}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: accentPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancellation or Return Button
            if (isCancellable)
              CustomButton(
                text: 'Cancel Order',
                variant: ButtonVariant.outline,
                onPressed: () => _showCancelDialog(context),
              )
            else if (isDelivered)
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Request Return / Refund',
                      variant: ButtonVariant.outline,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReturnRequestScreen(order: order),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: context.tr('rate_order'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MyReviewsScreen(
                              initialProduct: order.items.isNotEmpty
                                  ? order.items.first.product
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
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


