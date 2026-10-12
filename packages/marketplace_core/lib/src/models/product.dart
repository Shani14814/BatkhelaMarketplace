class Product {
  final String id;
  final String vendorId;
  final String? categoryId;
  final String? category;
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
    this.category,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.stockQuantity = 100,
    this.isAvailable = true,
    this.imageUrl,
    required this.createdAt,
  });

  String? get effectiveCategory => category ?? categoryId;

  double get effectivePrice => (discountPrice != null && discountPrice! > 0 && discountPrice! < price)
      ? discountPrice!
      : price;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawCat = (json['category'] ?? json['category_name'] ?? json['category_id'])?.toString();
    final nameStr = json['name'] as String? ?? 'Product';
    final descStr = json['description'] as String?;
    return Product(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      categoryId: json['category_id'] as String? ?? rawCat,
      category: (rawCat != null && rawCat.trim().isNotEmpty && rawCat != 'General')
          ? rawCat
          : _inferSubCategory(nameStr, descStr),
      name: nameStr,
      description: descStr,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 100,
      isAvailable: json['is_available'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static String _inferSubCategory(String name, String? description) {
    final text = '${name.toLowerCase()} ${(description ?? '').toLowerCase()}';
    if (text.contains('power bank') || text.contains('solar') || text.contains('battery')) {
      return 'Power & Energy';
    }
    if (text.contains('earbud') || text.contains('airpod') || text.contains('headphone') || text.contains('speaker') || text.contains('anc')) {
      return 'Audio & Earbuds';
    }
    if (text.contains('charger') || text.contains('adapter') || text.contains('cable') || text.contains('type-c')) {
      return 'Chargers & Cables';
    }
    if (text.contains('watch') || text.contains('amoled') || text.contains('smart')) {
      return 'Smart Watches';
    }
    if (text.contains('karahi') || text.contains('handi')) {
      return 'Karahi & Handi';
    }
    if (text.contains('tikka') || text.contains('kabab') || text.contains('bbq') || text.contains('seekh') || text.contains('platter')) {
      return 'BBQ & Grill';
    }
    if (text.contains('pulao') || text.contains('biryani') || text.contains('rice')) {
      return 'Rice & Pulao';
    }
    if (text.contains('burger') || text.contains('zinger') || text.contains('shawarma') || text.contains('wrap') || text.contains('pizza') || text.contains('fries')) {
      return 'Fast Food & Burgers';
    }
    if (text.contains('drink') || text.contains('pepsi') || text.contains('sting') || text.contains('shake') || text.contains('juice') || text.contains('tea') || text.contains('kahwa')) {
      return 'Drinks & Beverages';
    }
    if (text.contains('naan') || text.contains('roti') || text.contains('paratha') || text.contains('raita') || text.contains('salad')) {
      return 'Sides & Tandoor';
    }
    if (text.contains('cake') || text.contains('gulab') || text.contains('mithai') || text.contains('sweet') || text.contains('biscuit') || text.contains('rusk')) {
      return 'Sweets & Bakery';
    }
    if (text.contains('panadol') || text.contains('tablet') || text.contains('syrup') || text.contains('vitamin') || text.contains('first aid') || text.contains('thermometer') || text.contains('bp') || text.contains('ors')) {
      return 'Medicine & Care';
    }
    if (text.contains('atta') || text.contains('oil') || text.contains('ghee') || text.contains('sugar') || text.contains('daal') || text.contains('milk') || text.contains('egg')) {
      return 'Daily Grocery';
    }
    if (text.contains('apple') || text.contains('mango') || text.contains('banana') || text.contains('potato') || text.contains('tomato') || text.contains('onion') || text.contains('honey') || text.contains('walnut') || text.contains('almond')) {
      return 'Fresh Produce & Dry Fruit';
    }
    if (text.contains('shalwar') || text.contains('kameez') || text.contains('chappal') || text.contains('shawl') || text.contains('waistcoat') || text.contains('cap')) {
      return 'Traditional Fashion';
    }
    if (text.contains('cement') || text.contains('drill') || text.contains('paint') || text.contains('breaker') || text.contains('LED')) {
      return 'Tools & Hardware';
    }
    return 'Popular Specials';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'category_id': category ?? categoryId,
      'category': category ?? categoryId,
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

