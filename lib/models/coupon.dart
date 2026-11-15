class Coupon {
  final String code;
  final String title;
  final String description;
  final double discountAmount;
  final double discountPercentage;
  final double minSpend;
  final DateTime expiryDate;
  final bool isUsed;

  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    this.discountAmount = 0.0,
    this.discountPercentage = 0.0,
    this.minSpend = 0.0,
    required this.expiryDate,
    this.isUsed = false,
  });

  double calculateDiscount(double subtotal) {
    if (subtotal < minSpend) return 0.0;
    if (discountPercentage > 0) {
      return (subtotal * (discountPercentage / 100));
    }
    return discountAmount;
  }
}

