import '../../domain/models/models.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../services/mock_data_service.dart';

class CartRepository implements ICartRepository {
  final List<CartItem> _items = [];
  final List<Coupon> _coupons = MockDataService.getSampleCoupons();

  CartRepository() {
    _initSampleCart();
  }

  void _initSampleCart() {
    final products = MockDataService.getProducts();
    try {
      final fridge = products.firstWhere((p) => p.id == 'p_fridge_samsung_600');
      final washer = products.firstWhere((p) => p.id == 'p_washer_lg_9kg');
      final micro = products.firstWhere((p) => p.id == 'p_micro_samsung_32');

      _items.add(CartItem(product: fridge, quantity: 1));
      _items.add(CartItem(product: washer, quantity: 1));
      _items.add(CartItem(product: micro, quantity: 1));
    } catch (_) {}
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> addToCart(Product product, {int quantity = 1, String? selectedColor}) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedColor: selectedColor,
      ));
    }
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == productId);
    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex].quantity = quantity;
      }
    }
  }

  @override
  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
  }

  @override
  Future<void> clearCart() async {
    _items.clear();
  }

  @override
  Future<List<Coupon>> getAvailableCoupons() async {
    return List.unmodifiable(_coupons);
  }

  @override
  Future<Coupon?> validateCoupon(String code) async {
    final normalized = code.trim().toUpperCase();
    try {
      return _coupons.firstWhere((c) => c.code == normalized && !c.isUsed);
    } catch (_) {
      return null;
    }
  }
}

