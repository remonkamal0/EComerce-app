import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/i_wishlist_repository.dart';
import 'cart_view_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final IWishlistRepository _wishlistRepository;

  List<Product> _items = [];
  bool _isLoading = false;

  WishlistViewModel({required IWishlistRepository wishlistRepository})
      : _wishlistRepository = wishlistRepository {
    _loadWishlist();
  }

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  Future<void> _loadWishlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = List.from(await _wishlistRepository.getWishlist());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInWishlist(String productId) {
    return _items.any((p) => p.id == productId);
  }

  Future<bool> toggleWishlist(Product product) async {
    final added = await _wishlistRepository.toggleWishlist(product);
    _items = List.from(await _wishlistRepository.getWishlist());
    notifyListeners();
    return added;
  }

  Future<void> removeFromWishlist(String productId) async {
    final p = _items.firstWhere((item) => item.id == productId, orElse: () => _items.first);
    await _wishlistRepository.toggleWishlist(p);
    _items = List.from(await _wishlistRepository.getWishlist());
    notifyListeners();
  }

  Future<void> clearWishlist() async {
    await _wishlistRepository.clearWishlist();
    _items.clear();
    notifyListeners();
  }

  Future<int> addAllToCart(CartViewModel cartViewModel) async {
    int addedCount = 0;
    for (final product in _items) {
      if (product.inStock) {
        await cartViewModel.addToCart(product);
        addedCount++;
      }
    }
    return addedCount;
  }
}

