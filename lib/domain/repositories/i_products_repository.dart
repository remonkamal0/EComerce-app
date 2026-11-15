import '../models/models.dart';

abstract class IProductsRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<List<Category>> getCategories();
  Future<List<Product>> getFeaturedOffers();
  Future<List<Product>> searchProducts({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
    double? minRating,
    bool? inStockOnly,
    String? energyEfficiency,
    String? sortBy, // 'recommended', 'price_asc', 'price_desc', 'rating', 'newest'
  });
  Future<List<Product>> getSimilarProducts(String categoryId, String currentProductId);
  Future<List<Review>> getProductReviews(String productId);
  Future<void> addProductReview(Review review);
}

