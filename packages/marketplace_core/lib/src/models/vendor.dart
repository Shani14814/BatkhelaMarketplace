class Vendor {
  final String id;
  final String storeName;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final double commissionRate;
  final bool isOpen;
  final bool isVerified;
  final DateTime createdAt;

  const Vendor({
    required this.id,
    required this.storeName,
    required this.slug,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.commissionRate = 10.0,
    this.isOpen = true,
    this.isVerified = false,
    required this.createdAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      storeName: json['store_name'] as String? ?? 'Store',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 10.0,
      isOpen: json['is_open'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'slug': slug,
      'description': description,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'commission_rate': commissionRate,
      'is_open': isOpen,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
