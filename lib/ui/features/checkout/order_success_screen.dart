import 'package:flutter/material.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/lottie_success_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import '../orders/order_tracking_screen.dart';
import '../orders/order_details_screen.dart';
import '../main_navigation_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: Column(
            children: [
              const SizedBox(height: 12),
              // Lottie Success Confetti Animation
              const LottieSuccessView(size: 160),
              const SizedBox(height: 16),

              Text(
                l10n.tr('order_placed_success'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimaryColor,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                l10n.orderConfirmedMsg(order.id),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _buildRow(context, l10n.tr('order_number'), '#${order.id}'),
                    Divider(color: context.dividerColor),
                    _buildRow(context, l10n.tr('payment_method'), order.paymentMethod),
                    Divider(color: context.dividerColor),
                    _buildRow(context, l10n.tr('estimated_delivery'), l10n.tr('estimated_delivery_days')),
                    Divider(color: context.dividerColor),
                    _buildRow(context, l10n.tr('total_amount'), '\$${order.total.toInt()}', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Primary: Track Order
              CustomButton(
                text: l10n.tr('track_order'),
                icon: const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(order: order),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Secondary: View Order Details
              CustomButton(
                text: l10n.tr('view_order_details'),
                variant: ButtonVariant.outline,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(order: order),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                child: Text(
                  l10n.tr('continue_shopping'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: isBold ? accentPrimary : context.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}


