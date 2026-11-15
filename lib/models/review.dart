class Review {
  final String id;
  final String productId;
  final String productName;
  final String userName;
  final String userAvatar;
  final double rating;
  final DateTime date;
  final String comment;
  final bool isVerifiedPurchase;
  int helpfulCount;
  final List<String> images;

  Review({
    required this.id,
    required this.productId,
    required this.productName,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.date,
    required this.comment,
    this.isVerifiedPurchase = true,
    this.helpfulCount = 0,
    this.images = const [],
  });
}

