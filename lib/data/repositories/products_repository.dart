import '../../domain/models/models.dart';
import '../../domain/repositories/i_products_repository.dart';
import '../services/mock_data_service.dart';

class ProductsRepository implements IProductsRepository {
  List<Product> _products = [];
  List<Category> _categories = [];
  final Map<String, List<Review>> _reviews = {};

  ProductsRepository() {
    _products = MockDataService.getProducts();
    _categories = MockDataService.getCategories();
  }

  @override
  Future<List<Product>> getProducts() async {
    return List.unmodifiable(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<List<Product>> getFeaturedOffers() async {
    return _products.where((p) => p.isSpecialOffer || p.isFeatured).toList();
  }

  @override
  Future<List<Product>> searchProducts({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
    double? minRating,
    bool? inStockOnly,
    String? energyEfficiency,
    String? sortBy,
  }) async {
    var results = List<Product>.from(_products);

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      results = results.where((p) => p.categoryId == categoryId).toList();
    }

    if (minPrice != null) {
      results = results.where((p) => p.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      results = results.where((p) => p.price <= maxPrice).toList();
    }

    if (brands != null && brands.isNotEmpty) {
      results = results.where((p) => brands.contains(p.brand)).toList();
    }

    if (minRating != null) {
      results = results.where((p) => p.rating >= minRating).toList();
    }

    if (inStockOnly == true) {
      results = results.where((p) => p.inStock).toList();
    }

    if (energyEfficiency != null && energyEfficiency.isNotEmpty) {
      results = results.where((p) => p.energyRating == energyEfficiency).toList();
    }

    // Sort
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          results.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          // stable
          break;
        case 'recommended':
        default:
          results.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
          break;
      }
    }

    return results;
  }

  @override
  Future<List<Product>> getSimilarProducts(String categoryId, String currentProductId) async {
    return _products
        .where((p) => p.categoryId == categoryId && p.id != currentProductId)
        .take(5)
        .toList();
  }

  @override
  Future<List<Review>> getProductReviews(String productId) async {
    if (!_reviews.containsKey(productId)) {
      _reviews[productId] = MockDataService.getSampleReviews(productId);
    }
    return List.unmodifiable(_reviews[productId]!);
  }

  @override
  Future<void> addProductReview(Review review) async {
    if (!_reviews.containsKey(review.productId)) {
      _reviews[review.productId] = [];
    }
    _reviews[review.productId]!.insert(0, review);
  }
}

