class CustomerAddress {
  final String id;
  final String userId;
  final String title;
  final String fullAddress;
  final String? landmark;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;

  const CustomerAddress({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullAddress,
    this.landmark,
    this.city = 'Batkhela',
    this.latitude,
    this.longitude,
    this.isDefault = false,
    required this.createdAt,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Home',
      fullAddress: json['full_address'] as String? ?? '',
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? 'Batkhela',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'full_address': fullAddress,
      'landmark': landmark,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CustomerAddress copyWith({
    String? id,
    String? userId,
    String? title,
    String? fullAddress,
    String? landmark,
    String? city,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
