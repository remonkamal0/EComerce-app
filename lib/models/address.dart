class Address {
  final String id;
  final String recipientName;
  final String phone;
  final String city;
  final String area;
  final String street;
  final String building;
  final String apartment;
  final String instructions;
  final String label; // 'Home', 'Work', 'Other'
  final bool isDefault;

  const Address({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.area,
    required this.street,
    required this.building,
    required this.apartment,
    this.instructions = '',
    this.label = 'Home',
    this.isDefault = false,
  });

  String get formattedAddress {
    return '$street, $building, Apt $apartment, $area, $city';
  }

  Address copyWith({
    String? id,
    String? recipientName,
    String? phone,
    String? city,
    String? area,
    String? street,
    String? building,
    String? apartment,
    String? instructions,
    String? label,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
      instructions: instructions ?? this.instructions,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

