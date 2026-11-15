import 'package:flutter/foundation.dart' hide Category;
import '../../domain/models/models.dart';
import '../../domain/repositories/i_products_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final IProductsRepository _productsRepository;

  List<Product> _allProducts = [];
  List<Category> _categories = [];
  List<Product> _featuredOffers = [];
  List<Product> _searchResults = [];
  bool _isLoading = false;

  // Search & Filter State
  String _searchQuery = '';
  String? _selectedCategory;
  double _minPrice = 100.0;
  double _maxPrice = 1000.0;
  final Set<String> _selectedBrands = {};
  double? _minRating;
  bool _inStockOnly = false;
  String? _energyEfficiency;
  String _sortBy = 'recommended';
  final List<String> _recentSearches = ['Refrigerator', 'Samsung', 'Washing Machine', 'Smart TV'];

  // Comparison State
  final List<Product> _compareProducts = [];
  bool _highlightDifferences = false;

  ProductsViewModel({required IProductsRepository productsRepository})
      : _productsRepository = productsRepository {
    loadInitialData();
  }

  // Getters
  List<Product> get allProducts => _allProducts;
  List<Category> get categories => _categories;
  List<Category> get primaryCategories => _categories.where((c) => c.isPrimary).toList();
  List<Category> get moreCategories => _categories.where((c) => !c.isPrimary).toList();
  List<Product> get featuredOffers => _featuredOffers;
  List<Product> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  Set<String> get selectedBrands => _selectedBrands;
  double? get minRating => _minRating;
  bool get inStockOnly => _inStockOnly;
  String? get energyEfficiency => _energyEfficiency;
  String get sortBy => _sortBy;
  List<String> get recentSearches => _recentSearches;

  List<Product> get compareProducts => _compareProducts;
  bool get highlightDifferences => _highlightDifferences;

  int get activeFiltersCount {
    int count = 0;
    if (_selectedCategory != null && _selectedCategory != 'all') count++;
    if (_minPrice > 100.0 || _maxPrice < 1000.0) count++;
    count += _selectedBrands.length;
    if (_minRating != null) count++;
    if (_inStockOnly) count++;
    if (_energyEfficiency != null) count++;
    return count;
  }

  List<String> get activeFilterChips {
    final chips = <String>[];
    if (_selectedCategory != null && _selectedCategory != 'all') {
      final cat = _categories.firstWhere((c) => c.id == _selectedCategory, orElse: () => _categories.first);
      chips.add(cat.name);
    }
    for (final brand in _selectedBrands) {
      chips.add(brand);
    }
    if (_minPrice > 100.0 || _maxPrice < 1000.0) {
      chips.add('\$${_minPrice.toInt()} - \$${_maxPrice.toInt()}');
    }
    if (_inStockOnly) chips.add('In Stock');
    if (_minRating != null) chips.add('${_minRating!.toStringAsFixed(1)}+ Stars');
    if (_energyEfficiency != null) chips.add('Energy: $_energyEfficiency');
    return chips;
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await _productsRepository.getProducts();
      _categories = await _productsRepository.getCategories();
      _featuredOffers = await _productsRepository.getFeaturedOffers();
      _searchResults = List.from(_allProducts);

      // Initialize comparison with Samsung Fridge & LG Fridge as in mockup
      final fridgeSamsung = _allProducts.firstWhere((p) => p.id == 'p_fridge_samsung_600');
      final fridgeLg = _allProducts.firstWhere((p) => p.id == 'p_fridge_lg_620');
      _compareProducts.addAll([fridgeSamsung, fridgeLg]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.trim().isNotEmpty && !_recentSearches.contains(query.trim())) {
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    }
    applyFilters();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategory = categoryId;
    applyFilters();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    applyFilters();
  }

  void toggleBrand(String brand) {
    if (_selectedBrands.contains(brand)) {
      _selectedBrands.remove(brand);
    } else {
      _selectedBrands.add(brand);
    }
    applyFilters();
  }

  void setRating(double? rating) {
    _minRating = rating;
    applyFilters();
  }

  void toggleInStockOnly(bool value) {
    _inStockOnly = value;
    applyFilters();
  }

  void setEnergyEfficiency(String? efficiency) {
    _energyEfficiency = efficiency;
    applyFilters();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    applyFilters();
  }

  void resetFilters() {
    _selectedCategory = null;
    _minPrice = 100.0;
    _maxPrice = 1000.0;
    _selectedBrands.clear();
    _minRating = null;
    _inStockOnly = false;
    _energyEfficiency = null;
    _sortBy = 'recommended';
    applyFilters();
  }

  void removeFilterChip(String chip) {
    if (_selectedCategory != null) {
      final cat = _categories.firstWhere((c) => c.id == _selectedCategory, orElse: () => _categories.first);
      if (cat.name == chip) {
        _selectedCategory = null;
        applyFilters();
        return;
      }
    }
    if (_selectedBrands.contains(chip)) {
      _selectedBrands.remove(chip);
      applyFilters();
      return;
    }
    if (chip.contains('-')) {
      _minPrice = 100.0;
      _maxPrice = 1000.0;
      applyFilters();
      return;
    }
    if (chip == 'In Stock') {
      _inStockOnly = false;
      applyFilters();
      return;
    }
    if (chip.contains('Stars')) {
      _minRating = null;
      applyFilters();
      return;
    }
    if (chip.contains('Energy:')) {
      _energyEfficiency = null;
      applyFilters();
      return;
    }
  }

  Future<void> applyFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _productsRepository.searchProducts(
        query: _searchQuery,
        categoryId: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        brands: _selectedBrands.toList(),
        minRating: _minRating,
        inStockOnly: _inStockOnly,
        energyEfficiency: _energyEfficiency,
        sortBy: _sortBy,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Comparison controls
  void addToCompare(Product product) {
    if (_compareProducts.length < 4 && !_compareProducts.any((p) => p.id == product.id)) {
      _compareProducts.add(product);
      notifyListeners();
    }
  }

  void removeFromCompare(String productId) {
    _compareProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearComparison() {
    _compareProducts.clear();
    notifyListeners();
  }

  void toggleHighlightDifferences() {
    _highlightDifferences = !_highlightDifferences;
    notifyListeners();
  }

  Future<List<Product>> getSimilarProducts(String categoryId, String currentId) {
    return _productsRepository.getSimilarProducts(categoryId, currentId);
  }

  Future<List<Review>> getProductReviews(String productId) {
    return _productsRepository.getProductReviews(productId);
  }

  Future<void> addReview(Review review) async {
    await _productsRepository.addProductReview(review);
    notifyListeners();
  }
}

