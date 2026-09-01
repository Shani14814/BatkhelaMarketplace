class RiderProfile {
  final String id;
  final String userId;
  final String vehicleType;
  final String vehicleNumber;
  final String cnicNumber;
  final String? licenseNumber;
  final bool isVerified;
  final double rating;
  final int totalDeliveries;
  final String? fullName;
  final String? phone;

  const RiderProfile({
    required this.id,
    required this.userId,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.cnicNumber,
    this.licenseNumber,
    this.isVerified = false,
    this.rating = 5.0,
    this.totalDeliveries = 0,
    this.fullName,
    this.phone,
  });

  factory RiderProfile.fromJson(Map<String, dynamic> json) {
    return RiderProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vehicleType: json['vehicle_type'] as String? ?? 'Motorcycle (125cc)',
      vehicleNumber: json['vehicle_number'] as String? ?? '',
      cnicNumber: json['cnic_number'] as String? ?? '',
      licenseNumber: json['license_number'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalDeliveries: (json['total_deliveries'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'cnic_number': cnicNumber,
      'license_number': licenseNumber,
      'is_verified': isVerified,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
    };
  }

  RiderProfile copyWith({
    String? id,
    String? userId,
    String? vehicleType,
    String? vehicleNumber,
    String? cnicNumber,
    String? licenseNumber,
    bool? isVerified,
    double? rating,
    int? totalDeliveries,
    String? fullName,
    String? phone,
  }) {
    return RiderProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
    );
  }
}

class RiderEarning {
  final String id;
  final String riderId;
  final String orderId;
  final double deliveryFee;
  final double tips;
  final double bonus;
  final double netEarning;
  final DateTime createdAt;

  const RiderEarning({
    required this.id,
    required this.riderId,
    required this.orderId,
    required this.deliveryFee,
    this.tips = 0.0,
    this.bonus = 0.0,
    required this.netEarning,
    required this.createdAt,
  });

  factory RiderEarning.fromJson(Map<String, dynamic> json) {
    return RiderEarning(
      id: json['id'] as String,
      riderId: json['rider_id'] as String,
      orderId: json['order_id'] as String,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      netEarning: (json['net_earning'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rider_id': riderId,
      'order_id': orderId,
      'delivery_fee': deliveryFee,
      'tips': tips,
      'bonus': bonus,
      'net_earning': netEarning,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
