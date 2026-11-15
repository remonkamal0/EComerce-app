class FaqItem {
  final String id;
  final String category; // 'Orders & Delivery', 'Returns & Refunds', 'Warranty & Services', 'Payments'
  final String question;
  final String answer;

  const FaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });
}

