import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';
import '../orders/my_orders_screen.dart';
import '../home/featured_offers_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supportVm = context.watch<SupportViewModel>();
    final notifs = supportVm.notifications;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (supportVm.unreadNotificationsCount > 0)
            TextButton(
              onPressed: () => supportVm.markAllNotificationsAsRead(),
              child: const Text('Mark all read', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifs.isEmpty
          ? const EmptyStateView(
              icon: Icons.notifications_none_outlined,
              title: 'No Notifications',
              message: 'You are all caught up! Updates regarding your orders and offers will appear here.',
            )
          : ResponsiveConstrainedBox(
              maxWidth: ResponsiveLayout.maxReadableWidth,
              child: StaggeredListLimiter(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                  final n = notifs[index];

                  IconData icon;
                  Color iconColor;

                  switch (n.type) {
                    case 'order':
                      icon = Icons.receipt_long;
                      iconColor = AppColors.primary;
                      break;
                    case 'promo':
                      icon = Icons.local_offer_outlined;
                      iconColor = AppColors.ratingStar;
                      break;
                    case 'delivery':
                      icon = Icons.local_shipping_outlined;
                      iconColor = AppColors.info;
                      break;
                    default:
                      icon = Icons.notifications_outlined;
                      iconColor = AppColors.primary;
                  }

                  return StaggeredListItem(
                    index: index,
                    child: GestureDetector(
                  onTap: () {
                    supportVm.markNotificationAsRead(n.id);
                    if (n.actionRoute == '/orders') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                      );
                    } else if (n.actionRoute == '/offers') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FeaturedOffersScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.isRead ? context.cardBg : context.mintLightBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: n.isRead
                            ? context.borderColor
                            : (context.isDarkMode ? AppColors.darkBorder : AppColors.mintDark),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.surfaceBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Icon(icon, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondaryColor,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                );
              },
              ),
              ),
            ),
    );
  }
}


