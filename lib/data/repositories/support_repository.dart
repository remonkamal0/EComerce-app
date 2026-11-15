import '../../domain/models/models.dart';
import '../../domain/repositories/i_support_repository.dart';
import '../services/mock_data_service.dart';

class SupportRepository implements ISupportRepository {
  final List<FaqItem> _faqs = MockDataService.getSampleFaqs();
  final List<NotificationItem> _notifications = MockDataService.getSampleNotifications();

  @override
  Future<List<FaqItem>> getFaqs() async {
    return List.unmodifiable(_faqs);
  }

  @override
  Future<void> submitContactMessage({
    required String subject,
    required String message,
    String? orderId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index].isRead = true;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }
}

