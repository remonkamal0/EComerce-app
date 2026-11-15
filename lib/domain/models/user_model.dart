import '../../models/address.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final List<Address> addresses;
  final double walletBalance;
  final int ordersCount;
  final int wishlistCount;
  final double rating; // or reviews count
  final int reviewsCount;
  final bool isGuest;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
    this.addresses = const [],
    this.walletBalance = 50.0,
    this.ordersCount = 12,
    this.wishlistCount = 24,
    this.rating = 4.6,
    this.reviewsCount = 15,
    this.isGuest = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    List<Address>? addresses,
    double? walletBalance,
    int? ordersCount,
    int? wishlistCount,
    double? rating,
    int? reviewsCount,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addresses: addresses ?? this.addresses,
      walletBalance: walletBalance ?? this.walletBalance,
      ordersCount: ordersCount ?? this.ordersCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

