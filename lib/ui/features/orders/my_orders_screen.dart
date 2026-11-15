import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'order_tracking_screen.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersVm = context.watch<OrdersViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: MediaQuery.sizeOf(context).width < 380,
          tabAlignment: MediaQuery.sizeOf(context).width < 380 ? TabAlignment.start : TabAlignment.fill,
          indicatorColor: AppColors.primary,
          labelColor: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
          unselectedLabelColor: context.textSecondaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: 'Active (${ordersVm.activeOrders.length})'),
            Tab(text: 'Delivered (${ordersVm.deliveredOrders.length})'),
            Tab(text: 'Cancelled (${ordersVm.cancelledOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(ordersVm.activeOrders, 'No Active Orders', 'You currently do not have any pending orders in progress.'),
          _buildOrdersList(ordersVm.deliveredOrders, 'No Delivered Orders', 'Delivered orders and warranties will appear here.'),
          _buildOrdersList(ordersVm.cancelledOrders, 'No Cancelled Orders', 'Cancelled or returned orders will appear here.'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> list, String emptyTitle, String emptyDesc) {
    if (list.isEmpty) {
      return EmptyStateView(
        icon: Icons.receipt_long_outlined,
        title: emptyTitle,
        message: emptyDesc,
      );
    }

    return ResponsiveConstrainedBox(
      maxWidth: ResponsiveLayout.maxReadableWidth,
      child: StaggeredListLimiter(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final order = list[index];
            return StaggeredListItem(
              index: index,
              child: _buildOrderCard(context, order),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final cartVm = context.read<CartViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status == OrderStatus.cancelled || order.status == OrderStatus.returned
                      ? AppColors.discountBg
                      : context.mintBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: order.status == OrderStatus.cancelled || order.status == OrderStatus.returned
                        ? AppColors.error
                        : (context.isDarkMode ? AppColors.primaryLight : AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${order.date.day}/${order.date.month}/${order.date.year} • ${order.items.length} Item(s)',
            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 12),

          // Items Thumbnails Row
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...order.items.take(3).map((item) {
                          return Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 8),
                            child: ApplianceImage(
                              imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '',
                              borderRadius: 10,
                              fit: BoxFit.contain,
                            ),
                          );
                        }),
                        if (order.items.length > 3)
                          Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.surfaceBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '+${order.items.length - 3}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                    Text(
                      '\$${order.total.toInt()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  child: const Text(
                    'View Details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: (order.status != OrderStatus.cancelled && order.status != OrderStatus.returned)
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(order: order),
                            ),
                          );
                        }
                      : () {
                          for (final it in order.items) {
                            cartVm.addToCart(it.product, quantity: it.quantity);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Items added back to your cart!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                  child: Text(
                    (order.status != OrderStatus.cancelled && order.status != OrderStatus.returned)
                        ? 'Track Order'
                        : 'Reorder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


