import '../models/models.dart';

abstract class IOrdersRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<void> cancelOrder(String orderId, String reason);
  Future<void> requestReturn(String orderId, String reason, String refundMethod, String notes);
}

