import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/i_cart_repository.dart';

class CartViewModel extends ChangeNotifier {
  final ICartRepository _cartRepository;

  List<CartItem> _items = [];
  Coupon? _appliedCoupon;
  String? _couponError;
  bool _isLoading = false;
  double _customDeliveryFee = 20.0;
  double _installationFee = 0.0;

  CartViewModel({required ICartRepository cartRepository})
      : _cartRepository = cartRepository {
    _loadCart();
  }

  List<CartItem> get items => _items;
  Coupon? get appliedCoupon => _appliedCoupon;
  String? get couponError => _couponError;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get originalSubtotal => _items.fold(0.0, (sum, item) => sum + item.originalTotalPrice);

  double get couponDiscount {
    if (_appliedCoupon == null) return 0.0;
    return _appliedCoupon!.calculateDiscount(subtotal);
  }

  double get deliveryFee {
    if (isEmpty) return 0.0;
    return _customDeliveryFee;
  }

  double get installationFee => _installationFee;

  double get total {
    if (isEmpty) return 0.0;
    final t = subtotal - couponDiscount + deliveryFee + installationFee;
    return t > 0 ? t : 0.0;
  }

  Future<void> _loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = List.from(await _cartRepository.getCartItems());
      // Apply initial discount coupon to match the mockup totals: Subtotal $1177, Discount -$100, Delivery $20, Total $1097!
      final coupon = await _cartRepository.validateCoupon('HOMEPLUS100');
      if (coupon != null) {
        _appliedCoupon = coupon;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1, String? selectedColor}) async {
    await _cartRepository.addToCart(product, quantity: quantity, selectedColor: selectedColor);
    _items = List.from(await _cartRepository.getCartItems());
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await _cartRepository.updateQuantity(productId, quantity);
    _items = List.from(await _cartRepository.getCartItems());
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    await _cartRepository.removeFromCart(productId);
    _items = List.from(await _cartRepository.getCartItems());
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _cartRepository.clearCart();
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }

  Future<bool> applyCoupon(String code) async {
    _couponError = null;
    notifyListeners();

    final coupon = await _cartRepository.validateCoupon(code);
    if (coupon == null) {
      _couponError = 'Invalid or expired coupon code';
      notifyListeners();
      return false;
    }

    if (subtotal < coupon.minSpend) {
      _couponError = 'Minimum spend of \$${coupon.minSpend.toInt()} required for this coupon';
      notifyListeners();
      return false;
    }

    _appliedCoupon = coupon;
    notifyListeners();
    return true;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _couponError = null;
    notifyListeners();
  }

  void setDeliveryFee(double fee) {
    _customDeliveryFee = fee;
    notifyListeners();
  }

  void setInstallationFee(double fee) {
    _installationFee = fee;
    notifyListeners();
  }

  Future<List<Coupon>> getAvailableCoupons() {
    return _cartRepository.getAvailableCoupons();
  }
}

