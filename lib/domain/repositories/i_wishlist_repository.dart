import '../models/models.dart';

abstract class IWishlistRepository {
  Future<List<Product>> getWishlist();
  Future<bool> toggleWishlist(Product product);
  Future<bool> isInWishlist(String productId);
  Future<void> clearWishlist();
}

