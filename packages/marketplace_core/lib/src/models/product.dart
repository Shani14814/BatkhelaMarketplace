class Product {
  final String id;
  final String vendorId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.vendorId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.stockQuantity = 100,
    this.isAvailable = true,
    this.imageUrl,
    required this.createdAt,
  });

  double get effectivePrice => (discountPrice != null && discountPrice! > 0 && discountPrice! < price)
      ? discountPrice!
      : price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String? ?? 'Product',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 100,
      isAvailable: json['is_available'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'stock_quantity': stockQuantity,
      'is_available': isAvailable,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
