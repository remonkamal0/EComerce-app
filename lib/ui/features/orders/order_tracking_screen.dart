import 'package:flutter/material.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import '../support/live_chat_screen.dart';
import 'order_details_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Order Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.headphones_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LiveChatScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Status Hero Card (Mockup Match)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.mintBg,
                borderRadius: BorderRadius.circular(20),
                border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.status == OrderStatus.confirmed
                        ? 'Order Confirmed!'
                        : order.status == OrderStatus.preparing
                            ? 'Preparing in Warehouse'
                            : order.status == OrderStatus.outForDelivery
                                ? 'Out for Delivery!'
                                : 'Order Delivered!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your order #${order.id} has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stepper Progress Timeline (Mockup Match)
            _buildTimeline(context),
            const SizedBox(height: 20),

            // Delivery Details Card (Mockup Match)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: accentPrimary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.deliveryAddress.formattedAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.textSecondaryColor, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Realistic Map Visualization (Mockup Match)
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.isDarkMode ? context.surfaceLightBg : const Color(0xFFF0F3F1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _TrackingMapPainter(isDark: context.isDarkMode),
                  child: Stack(
                    children: [
                      // Moving truck indicator
                      Positioned(
                        left: 140,
                        top: 55,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      // Destination House Pin
                      Positioned(
                        right: 24,
                        top: 40,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.cardBg.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.estimatedDelivery,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accentPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Items Summary (Mockup Match)
            if (firstItem != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Items',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(order: order),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accentPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward, size: 12, color: accentPrimary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: ApplianceImage(
                            imageUrl: firstItem.product.images.isNotEmpty
                                ? firstItem.product.images.first
                                : '',
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
                                context.l10n.productName(firstItem.product.id, firstItem.product.name),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${firstItem.product.price.toInt()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: accentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Qty: ${firstItem.quantity}',
                          style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Need Help? Chat shortcut (Mockup Match)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveChatScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.mintLightBg,
                  borderRadius: BorderRadius.circular(16),
                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: accentPrimary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          Text(
                            'Chat with our support team',
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: accentPrimary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final steps = [
      {'title': 'Confirmed', 'time': 'Apr 24, 10:30 AM', 'done': true},
      {'title': 'Preparing', 'time': 'Apr 24, 12:00 PM', 'done': order.status != OrderStatus.confirmed},
      {'title': 'Out for Delivery', 'time': '', 'done': order.status == OrderStatus.outForDelivery || order.status == OrderStatus.delivered},
      {'title': 'Delivered', 'time': '', 'done': order.status == OrderStatus.delivered},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                final isDone = steps[stepIndex]['done'] as bool;
                return Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary : context.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? AppColors.primary : context.borderColor,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Center(
                          child: Icon(Icons.check, size: 12, color: Colors.white),
                        )
                      : null,
                );
              } else {
                final nextStepIndex = (index + 1) ~/ 2;
                final isPassed = steps[nextStepIndex]['done'] as bool;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? AppColors.primary : context.borderColor,
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.map((s) {
              return SizedBox(
                width: 76,
                child: Column(
                  children: [
                    Text(
                      s['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    if ((s['time'] as String).isNotEmpty)
                      Text(
                        s['time'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, color: context.textSecondaryColor),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TrackingMapPainter extends CustomPainter {
  final bool isDark;
  _TrackingMapPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? AppColors.darkBorder.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Subtle background street grid lines
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), gridPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.25, size.height), gridPaint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.55, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.7), gridPaint);

    // Green Delivery Path
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(30, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.35, size.height * 0.85, size.width * 0.45, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.65, size.height * 0.25, size.width - 40, size.height * 0.35);

    canvas.drawPath(path, routePaint);

    // Start Dot
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(30, size.height * 0.75), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


