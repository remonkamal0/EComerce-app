import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/i_orders_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final IOrdersRepository _ordersRepository;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  OrderModel? _selectedOrder;

  OrdersViewModel({required IOrdersRepository ordersRepository})
      : _ordersRepository = ordersRepository {
    _loadOrders();
  }

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  OrderModel? get selectedOrder => _selectedOrder;

  List<OrderModel> get activeOrders => _orders
      .where((o) =>
          o.status == OrderStatus.confirmed ||
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.outForDelivery)
      .toList();

  List<OrderModel> get deliveredOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).toList();

  List<OrderModel> get cancelledOrders => _orders
      .where((o) => o.status == OrderStatus.cancelled || o.status == OrderStatus.returned)
      .toList();

  Future<void> _loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = List.from(await _ordersRepository.getOrders());
      if (_orders.isNotEmpty) {
        _selectedOrder = _orders.first;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  Future<OrderModel> createAndPlaceOrder({
    required List<CartItem> items,
    required Address address,
    required String deliveryMethod,
    required String paymentMethod,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double installationFee,
    required double total,
    bool hasInstallation = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final orderId = 'HP${(now.millisecondsSinceEpoch ~/ 1000).toString().substring(2)}';

      final newOrder = OrderModel(
        id: orderId,
        date: now,
        items: List.from(items),
        deliveryAddress: address,
        deliveryMethod: deliveryMethod,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        discount: discount,
        deliveryFee: deliveryFee,
        installationFee: installationFee,
        total: total,
        status: OrderStatus.confirmed,
        estimatedDelivery: 'Expected delivery in 2 business days',
        trackingNumber: 'TRK-$orderId',
        hasInstallation: hasInstallation,
        timeline: [
          OrderTimelineEvent(
            status: OrderStatus.confirmed,
            title: 'Order Confirmed',
            timestamp: now,
            isCompleted: true,
          ),
          OrderTimelineEvent(
            status: OrderStatus.preparing,
            title: 'Preparing in Warehouse',
            timestamp: now.add(const Duration(hours: 2)),
            isCompleted: false,
          ),
          OrderTimelineEvent(
            status: OrderStatus.outForDelivery,
            title: 'Out for Delivery',
            timestamp: now.add(const Duration(days: 1)),
            isCompleted: false,
          ),
          OrderTimelineEvent(
            status: OrderStatus.delivered,
            title: 'Delivered',
            timestamp: now.add(const Duration(days: 2)),
            isCompleted: false,
          ),
        ],
      );

      final placed = await _ordersRepository.placeOrder(newOrder);
      _orders.insert(0, placed);
      _selectedOrder = placed;
      return placed;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    await _ordersRepository.cancelOrder(orderId, reason);
    _orders = List.from(await _ordersRepository.getOrders());
    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _orders.firstWhere((o) => o.id == orderId);
    }
    notifyListeners();
  }

  Future<void> requestReturn(String orderId, String reason, String refundMethod, String notes) async {
    await _ordersRepository.requestReturn(orderId, reason, refundMethod, notes);
    _orders = List.from(await _ordersRepository.getOrders());
    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _orders.firstWhere((o) => o.id == orderId);
    }
    notifyListeners();
  }
}

