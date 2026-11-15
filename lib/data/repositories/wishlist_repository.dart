import '../../domain/models/models.dart';
import '../../domain/repositories/i_wishlist_repository.dart';
import '../services/mock_data_service.dart';

class WishlistRepository implements IWishlistRepository {
  final List<Product> _wishlist = [];

  WishlistRepository() {
    _initSampleWishlist();
  }

  void _initSampleWishlist() {
    final products = MockDataService.getProducts();
    final ids = [
      'p_fridge_samsung_600',
      'p_washer_lg_9kg',
      'p_ac_daikin_15',
      'p_micro_samsung_32',
    ];
    for (final id in ids) {
      try {
        final p = products.firstWhere((item) => item.id == id);
        _wishlist.add(p);
      } catch (_) {}
    }
  }

  @override
  Future<List<Product>> getWishlist() async {
    return List.unmodifiable(_wishlist);
  }

  @override
  Future<bool> toggleWishlist(Product product) async {
    final index = _wishlist.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _wishlist.removeAt(index);
      return false; // removed
    } else {
      _wishlist.add(product);
      return true; // added
    }
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    return _wishlist.any((p) => p.id == productId);
  }

  @override
  Future<void> clearWishlist() async {
    _wishlist.clear();
  }
}

