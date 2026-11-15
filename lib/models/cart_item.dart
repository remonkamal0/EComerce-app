import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;
  double get originalTotalPrice => product.originalPrice * quantity;
  double get totalSavings => (product.originalPrice - product.price) * quantity;
}

