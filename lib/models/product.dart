class ProductFeature {
  final String title;
  final String subtitle;
  final String iconKey; // 'snowflake', 'bolt', 'shield', 'box', 'tv', 'flame', etc.

  const ProductFeature({
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String categoryName;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockCount;
  final String description;
  final List<String> images;
  final List<ProductFeature> features;
  final Map<String, String> specifications;
  final Map<String, String> deliveryInfo;
  final bool isFeatured;
  final bool isSpecialOffer;
  final String energyRating; // 'A+++', 'A++', 'A+', 'A', etc.
  final String capacity;     // e.g. '600 L', '10.5 kg', '55 inch', '50 L'
  final String dimensions;   // e.g. '70 x 72 x 180 cm'
  final String warranty;     // e.g. '2 Years', '5 Years'
  final bool hasNoFrost;
  final List<String> colors;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    this.inStock = true,
    this.stockCount = 15,
    required this.description,
    required this.images,
    this.features = const [],
    this.specifications = const {},
    this.deliveryInfo = const {},
    this.isFeatured = false,
    this.isSpecialOffer = false,
    this.energyRating = 'A++',
    this.capacity = '',
    this.dimensions = '',
    this.warranty = '2 Years',
    this.hasNoFrost = false,
    this.colors = const [],
  });

  int get discountPercent {
    if (originalPrice <= price || originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? categoryId,
    String? categoryName,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    bool? inStock,
    int? stockCount,
    String? description,
    List<String>? images,
    List<ProductFeature>? features,
    Map<String, String>? specifications,
    Map<String, String>? deliveryInfo,
    bool? isFeatured,
    bool? isSpecialOffer,
    String? energyRating,
    String? capacity,
    String? dimensions,
    String? warranty,
    bool? hasNoFrost,
    List<String>? colors,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      stockCount: stockCount ?? this.stockCount,
      description: description ?? this.description,
      images: images ?? this.images,
      features: features ?? this.features,
      specifications: specifications ?? this.specifications,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      isFeatured: isFeatured ?? this.isFeatured,
      isSpecialOffer: isSpecialOffer ?? this.isSpecialOffer,
      energyRating: energyRating ?? this.energyRating,
      capacity: capacity ?? this.capacity,
      dimensions: dimensions ?? this.dimensions,
      warranty: warranty ?? this.warranty,
      hasNoFrost: hasNoFrost ?? this.hasNoFrost,
      colors: colors ?? this.colors,
    );
  }
}

