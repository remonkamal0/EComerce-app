import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/i_support_repository.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class SupportViewModel extends ChangeNotifier {
  final ISupportRepository _supportRepository;

  List<FaqItem> _faqs = [];
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String _faqSearchQuery = '';

  // Live Chat state
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      id: 'msg_1',
      text: 'Hello Ahmed! 👋 Welcome to HomePlus Customer Care. How may I assist you with your home appliances today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  SupportViewModel({required ISupportRepository supportRepository})
      : _supportRepository = supportRepository {
    loadData();
  }

  List<FaqItem> get faqs {
    if (_faqSearchQuery.trim().isEmpty) return _faqs;
    final q = _faqSearchQuery.toLowerCase();
    return _faqs
        .where((f) => f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q))
        .toList();
  }

  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  List<ChatMessage> get chatMessages => _chatMessages;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _faqs = List.from(await _supportRepository.getFaqs());
      _notifications = List.from(await _supportRepository.getNotifications());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchFaqs(String query) {
    _faqSearchQuery = query;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _supportRepository.markNotificationAsRead(id);
    _notifications = List.from(await _supportRepository.getNotifications());
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    await _supportRepository.markAllNotificationsAsRead();
    _notifications = List.from(await _supportRepository.getNotifications());
    notifyListeners();
  }

  Future<void> submitContactMessage({
    required String subject,
    required String message,
    String? orderId,
  }) async {
    await _supportRepository.submitContactMessage(
      subject: subject,
      message: message,
      orderId: orderId,
    );
  }

  // Interactive Live Chat
  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMsg);
    notifyListeners();

    // Generate intelligent simulated response
    Future.delayed(const Duration(milliseconds: 900), () {
      final reply = _generateBotReply(text.trim());
      _chatMessages.add(ChatMessage(
        id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  String _generateBotReply(String userQuery) {
    final lower = userQuery.toLowerCase();
    if (lower.contains('order') || lower.contains('track') || lower.contains('where')) {
      return 'You can track active deliveries under "My Orders" or "Track Your Order". Order #HP123456 is currently being prepared and scheduled for delivery tomorrow between 10:00 AM – 2:00 PM!';
    } else if (lower.contains('return') || lower.contains('refund')) {
      return 'HomePlus offers a 14-day hassle-free return policy. You can submit a return request directly from your Order Details screen, and our courier will inspect and collect the item.';
    } else if (lower.contains('install') || lower.contains('setup')) {
      return 'Yes! We offer professional unboxing & installation by certified technicians for \$25. You can select this option at checkout or schedule it with support.';
    } else if (lower.contains('warranty') || lower.contains('guarantee')) {
      return 'All appliances on HomePlus carry 2 to 5 years official manufacturer warranty. Your order invoice serves as the authorized warranty deed.';
    } else {
      return 'Thank you for reaching out! A senior support specialist has received your inquiry and is reviewing your account details. Is there anything else you would like assistance with?';
    }
  }
}

