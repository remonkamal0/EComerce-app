import '../models/models.dart';

abstract class ICartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(Product product, {int quantity = 1, String? selectedColor});
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeFromCart(String productId);
  Future<void> clearCart();
  Future<List<Coupon>> getAvailableCoupons();
  Future<Coupon?> validateCoupon(String code);
}

