class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String type; // 'order', 'promo', 'delivery', 'account'
  final String? actionRoute;
  final dynamic actionPayload;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.actionRoute,
    this.actionPayload,
  });
}

