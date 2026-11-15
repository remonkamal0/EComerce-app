import '../models/models.dart';

abstract class ISupportRepository {
  Future<List<FaqItem>> getFaqs();
  Future<void> submitContactMessage({
    required String subject,
    required String message,
    String? orderId,
  });
  Future<List<NotificationItem>> getNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsAsRead();
}

