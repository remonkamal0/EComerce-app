import 'cart_item.dart';
import 'address.dart';

enum OrderStatus {
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

class OrderTimelineEvent {
  final OrderStatus status;
  final String title;
  final DateTime timestamp;
  final bool isCompleted;

  const OrderTimelineEvent({
    required this.status,
    required this.title,
    required this.timestamp,
    required this.isCompleted,
  });
}

class OrderModel {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final Address deliveryAddress;
  final String deliveryMethod; // 'Standard', 'Express', 'Scheduled'
  final String paymentMethod;  // 'Cash on Delivery', 'Credit / Debit Card', etc.
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double installationFee;
  final double total;
  final OrderStatus status;
  final List<OrderTimelineEvent> timeline;
  final String? trackingNumber;
  final String estimatedDelivery;
  final bool hasInstallation;
  final String? returnReason;

  const OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.deliveryAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    this.installationFee = 0.0,
    required this.total,
    required this.status,
    required this.timeline,
    this.trackingNumber,
    required this.estimatedDelivery,
    this.hasInstallation = false,
    this.returnReason,
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  OrderModel copyWith({
    String? id,
    DateTime? date,
    List<CartItem>? items,
    Address? deliveryAddress,
    String? deliveryMethod,
    String? paymentMethod,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? installationFee,
    double? total,
    OrderStatus? status,
    List<OrderTimelineEvent>? timeline,
    String? trackingNumber,
    String? estimatedDelivery,
    bool? hasInstallation,
    String? returnReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      date: date ?? this.date,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      installationFee: installationFee ?? this.installationFee,
      total: total ?? this.total,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      hasInstallation: hasInstallation ?? this.hasInstallation,
      returnReason: returnReason ?? this.returnReason,
    );
  }
}

