class Category {
  final String id;
  final String name;
  final String group; // 'Major Appliances', 'Electronics', 'Home Essentials', 'Home & Living'
  final String image;
  final String iconKey;
  final int productCount;
  final bool isPrimary;

  const Category({
    required this.id,
    required this.name,
    required this.group,
    required this.image,
    required this.iconKey,
    this.productCount = 0,
    this.isPrimary = true,
  });
}

