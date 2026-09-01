class PlatformSetting {
  final String key;
  final dynamic value;
  final String? description;

  const PlatformSetting({
    required this.key,
    required this.value,
    this.description,
  });

  factory PlatformSetting.fromJson(Map<String, dynamic> json) {
    return PlatformSetting(
      key: json['key'] as String,
      value: json['value'],
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'description': description,
    };
  }
}

class ServiceCity {
  final String id;
  final String name;
  final String province;
  final bool isActive;
  final double deliveryRadiusKm;

  const ServiceCity({
    required this.id,
    required this.name,
    this.province = 'Khyber Pakhtunkhwa',
    this.isActive = true,
    this.deliveryRadiusKm = 15.0,
  });

  factory ServiceCity.fromJson(Map<String, dynamic> json) {
    return ServiceCity(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Batkhela',
      province: json['province'] as String? ?? 'Khyber Pakhtunkhwa',
      isActive: json['is_active'] as bool? ?? true,
      deliveryRadiusKm: (json['delivery_radius_km'] as num?)?.toDouble() ?? 15.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'is_active': isActive,
      'delivery_radius_km': deliveryRadiusKm,
    };
  }

  ServiceCity copyWith({
    String? id,
    String? name,
    String? province,
    bool? isActive,
    double? deliveryRadiusKm,
  }) {
    return ServiceCity(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      isActive: isActive ?? this.isActive,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
    );
  }
}

class Promotion {
  final String id;
  final String code;
  final String title;
  final double discountPercent;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final bool isActive;
  final DateTime? validUntil;

  const Promotion({
    required this.id,
    required this.code,
    required this.title,
    required this.discountPercent,
    this.maxDiscountAmount,
    this.minOrderAmount = 0.0,
    this.isActive = true,
    this.validUntil,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      validUntil: json['valid_until'] != null ? DateTime.tryParse(json['valid_until'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'discount_percent': discountPercent,
      'max_discount_amount': maxDiscountAmount,
      'min_order_amount': minOrderAmount,
      'is_active': isActive,
      'valid_until': validUntil?.toIso8601String(),
    };
  }

  Promotion copyWith({
    String? id,
    String? code,
    String? title,
    double? discountPercent,
    double? maxDiscountAmount,
    double? minOrderAmount,
    bool? isActive,
    DateTime? validUntil,
  }) {
    return Promotion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isActive: isActive ?? this.isActive,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
