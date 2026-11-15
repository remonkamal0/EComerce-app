import '../../domain/models/models.dart';
import '../../domain/repositories/i_orders_repository.dart';
import '../services/mock_data_service.dart';

class OrdersRepository implements IOrdersRepository {
  final List<OrderModel> _orders = [];

  OrdersRepository() {
    _initSampleOrders();
  }

  void _initSampleOrders() {
    final products = MockDataService.getProducts();
    final address = MockDataService.getDefaultAddress();

    try {
      final fridge = products.firstWhere((p) => p.id == 'p_fridge_samsung_600');
      final washer = products.firstWhere((p) => p.id == 'p_washer_lg_9kg');

      // 1. Order #HP123456 (Matches Tracking mockup)
      _orders.add(
        OrderModel(
          id: 'HP123456',
          date: DateTime(2026, 4, 24, 10, 30),
          items: [
            CartItem(product: fridge, quantity: 1),
          ],
          deliveryAddress: address,
          deliveryMethod: 'Standard Delivery',
          paymentMethod: 'Cash on Delivery',
          subtotal: 599.0,
          discount: 0.0,
          deliveryFee: 20.0,
          total: 619.0,
          status: OrderStatus.preparing,
          estimatedDelivery: 'Tomorrow, between 10:00 AM – 2:00 PM',
          trackingNumber: 'TRK-HP-994820',
          timeline: [
            OrderTimelineEvent(
              status: OrderStatus.confirmed,
              title: 'Order Confirmed',
              timestamp: DateTime(2026, 4, 24, 10, 30),
              isCompleted: true,
            ),
            OrderTimelineEvent(
              status: OrderStatus.preparing,
              title: 'Preparing in Warehouse',
              timestamp: DateTime(2026, 4, 24, 12, 0),
              isCompleted: true,
            ),
            OrderTimelineEvent(
              status: OrderStatus.outForDelivery,
              title: 'Out for Delivery',
              timestamp: DateTime(2026, 4, 25, 9, 0),
              isCompleted: false,
            ),
            OrderTimelineEvent(
              status: OrderStatus.delivered,
              title: 'Delivered',
              timestamp: DateTime(2026, 4, 25, 14, 0),
              isCompleted: false,
            ),
          ],
        ),
      );

      // 2. Order #HP84920 (Delivered)
      _orders.add(
        OrderModel(
          id: 'HP84920',
          date: DateTime(2026, 4, 10, 14, 15),
          items: [
            CartItem(product: washer, quantity: 1),
          ],
          deliveryAddress: address,
          deliveryMethod: 'Express Delivery',
          paymentMethod: 'Credit / Debit Card',
          subtotal: 449.0,
          discount: 50.0,
          deliveryFee: 0.0,
          installationFee: 25.0,
          total: 424.0,
          status: OrderStatus.delivered,
          estimatedDelivery: 'Delivered on Apr 11, 2026',
          trackingNumber: 'TRK-HP-849201',
          hasInstallation: true,
          timeline: [
            OrderTimelineEvent(
              status: OrderStatus.confirmed,
              title: 'Order Confirmed',
              timestamp: DateTime(2026, 4, 10, 14, 15),
              isCompleted: true,
            ),
            OrderTimelineEvent(
              status: OrderStatus.preparing,
              title: 'Prepared',
              timestamp: DateTime(2026, 4, 10, 16, 0),
              isCompleted: true,
            ),
            OrderTimelineEvent(
              status: OrderStatus.outForDelivery,
              title: 'Out for Delivery',
              timestamp: DateTime(2026, 4, 11, 10, 0),
              isCompleted: true,
            ),
            OrderTimelineEvent(
              status: OrderStatus.delivered,
              title: 'Delivered & Installed',
              timestamp: DateTime(2026, 4, 11, 12, 30),
              isCompleted: true,
            ),
          ],
        ),
      );
    } catch (_) {}
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    return List.unmodifiable(_orders);
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(
        status: OrderStatus.cancelled,
        returnReason: reason,
      );
    }
  }

  @override
  Future<void> requestReturn(String orderId, String reason, String refundMethod, String notes) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(
        status: OrderStatus.returned,
        returnReason: '$reason ($refundMethod): $notes',
      );
    }
  }
}

