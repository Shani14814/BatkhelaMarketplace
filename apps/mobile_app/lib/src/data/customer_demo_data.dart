import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

/// Promotional Hero Campaign Banner Model
class MarketplacePromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String ctaLabel;
  final Color primaryColor;
  final Color accentColor;
  final IconData icon;
  final String imageUrl;
  final String targetCategoryId;

  const MarketplacePromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.ctaLabel,
    required this.primaryColor,
    required this.accentColor,
    required this.icon,
    required this.imageUrl,
    this.targetCategoryId = 'all',
  });
}

/// Category Model for Customer Marketplace Navigation
class MarketplaceCategory {
  final String id;
  final String name;
  final String urduName;
  final IconData icon;
  final Color accentColor;
  final String emoji;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.urduName,
    required this.icon,
    required this.accentColor,
    this.emoji = '⭐',
  });
}

/// Store Model with UI metadata for Customer Discovery & Vendor Switching
class DemoStore {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String description;
  final String address;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final List<String> badges;
  final bool isOpen;
  final String? imageUrl;
  final String? logoUrl;
  final String ownerName;
  final String phone;
  final String operatingHours;
  final List<Product> products;

  const DemoStore({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    this.badges = const [],
    this.isOpen = true,
    this.imageUrl,
    this.logoUrl,
    this.ownerName = 'Verified Batkhela Merchant',
    this.phone = '+92 345 9876543',
    this.operatingHours = '09:00 AM – 11:00 PM (Daily)',
    this.products = const [],
  });

  Map<String, dynamic> toJson({int sortOrder = 99}) {
    return {
      'id': id,
      'sort_order': sortOrder,
      'name': name,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'address': address,
      'rating': rating,
      'review_count': reviewCount,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'badges': badges,
      'is_open': isOpen,
      'image_url': imageUrl,
      'logo_url': logoUrl,
      'owner_name': ownerName,
      'phone': phone,
      'operating_hours': operatingHours,
    };
  }

  factory DemoStore.fromJson(Map<String, dynamic> json, List<Product> storeProducts) {
    return DemoStore(
      id: json['id']?.toString() ?? 'store-1',
      name: json['name']?.toString() ?? 'Batkhela Store',
      categoryId: json['category_id']?.toString() ?? 'food',
      categoryName: json['category_name']?.toString() ?? 'Restaurants & BBQ',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? 'Main Bazaar, Batkhela',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 50,
      deliveryTime: json['delivery_time']?.toString() ?? '25-35 min',
      deliveryFee: json['delivery_fee']?.toString() ?? 'PKR 60',
      badges: (json['badges'] is List)
          ? (json['badges'] as List).map((e) => e.toString()).toList()
          : const ['Verified'],
      isOpen: json['is_open'] is bool ? json['is_open'] as bool : true,
      imageUrl: json['image_url']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      ownerName: json['owner_name']?.toString() ?? 'Verified Batkhela Merchant',
      phone: json['phone']?.toString() ?? '+92 345 9876543',
      operatingHours: json['operating_hours']?.toString() ?? '09:00 AM – 11:00 PM (Daily)',
      products: storeProducts,
    );
  }
}

/// Centralized Local Demo Data for Batkhela Marketplace
class CustomerDemoData {
  static String activeDeliveryAddress = 'Main Bazaar, Near Clock Tower, Batkhela';

  // Promotional Hero Banners (Arby's-style crafted visual banners with product photography)
  static const List<MarketplacePromoBanner> promoBanners = [
    MarketplacePromoBanner(
      id: 'banner-1',
      title: 'FAST FOOD.\nBURGERS &\nKARAHI.',
      subtitle: 'Big flavor. Bold Batkhela choices.',
      tag: 'HOT & FRESH',
      ctaLabel: 'Order Now',
      primaryColor: Color(0xFFB91C1C),
      accentColor: Color(0xFF7F1D1D),
      icon: Icons.lunch_dining,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80',
      targetCategoryId: 'fastfood',
    ),
    MarketplacePromoBanner(
      id: 'banner-2',
      title: 'DAILY GROCERY.\nFARM FRESH.\nDELIVERED.',
      subtitle: 'Atta, Rice, Milk & Sabzi in 25 mins.',
      tag: 'SUPER MART',
      ctaLabel: 'Shop Grocery',
      primaryColor: Color(0xFF0F766E),
      accentColor: Color(0xFF115E59),
      icon: Icons.shopping_basket,
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=80',
      targetCategoryId: 'grocery',
    ),
    MarketplacePromoBanner(
      id: 'banner-3',
      title: '24/7 MEDICINE.\nPHARMACY\nEXPRESS.',
      subtitle: 'Genuine medicines & care at your door.',
      tag: 'HEALTH CARE',
      ctaLabel: 'Order Meds',
      primaryColor: Color(0xFF9F1239),
      accentColor: Color(0xFF881337),
      icon: Icons.medical_services_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
      targetCategoryId: 'pharmacy',
    ),
    MarketplacePromoBanner(
      id: 'banner-4',
      title: 'CHILLED DRINKS.\nSHAKES &\nBAKERY.',
      subtitle: 'Ice-cold beverages, shakes & sweets.',
      tag: 'COOL & SWEET',
      ctaLabel: 'Order Drinks',
      primaryColor: Color(0xFF1E3A8A),
      accentColor: Color(0xFF172554),
      icon: Icons.local_drink,
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=600&auto=format&fit=crop&q=80',
      targetCategoryId: 'colddrinks',
    ),
    MarketplacePromoBanner(
      id: 'banner-5',
      title: 'SHINWARI BBQ.\nTIKKA & MUTTON\nPERFECTED.',
      subtitle: 'Charcoal grilled specialties across Batkhela.',
      tag: 'BBQ FEAST',
      ctaLabel: 'Order BBQ',
      primaryColor: Color(0xFF9A3412),
      accentColor: Color(0xFF7C2D12),
      icon: Icons.local_fire_department,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
      targetCategoryId: 'restaurants',
    ),
  ];

  // Primary Categories (Icon Tiles with Emojis for Arby's-style Horizontal Carousel)
  static const List<MarketplaceCategory> categories = [
    MarketplaceCategory(
      id: 'all',
      name: 'Featured',
      urduName: 'تمام',
      icon: Icons.star_rounded,
      accentColor: Color(0xFFC8102E),
      emoji: '⭐',
    ),
    MarketplaceCategory(
      id: 'grocery',
      name: 'Grocery',
      urduName: 'کریانہ و راشن',
      icon: Icons.shopping_basket_rounded,
      accentColor: Color(0xFF15803D),
      emoji: '🛒',
    ),
    MarketplaceCategory(
      id: 'pharmacy',
      name: 'Medicine',
      urduName: 'فارمیسی و ادویات',
      icon: Icons.medication_rounded,
      accentColor: Color(0xFFDC2626),
      emoji: '💊',
    ),
    MarketplaceCategory(
      id: 'fastfood',
      name: 'Fast Food',
      urduName: 'برگر اور فاسٹ فوڈ',
      icon: Icons.lunch_dining_rounded,
      accentColor: Color(0xFFD97706),
      emoji: '🍔',
    ),
    MarketplaceCategory(
      id: 'colddrinks',
      name: 'Cold Drinks',
      urduName: 'کولڈ ڈرنکس اور شیکس',
      icon: Icons.local_drink_rounded,
      accentColor: Color(0xFF0284C7),
      emoji: '🥤',
    ),
    MarketplaceCategory(
      id: 'restaurants',
      name: 'BBQ & Karahi',
      urduName: 'ریستوران و تکہ',
      icon: Icons.restaurant_rounded,
      accentColor: Color(0xFFB91C1C),
      emoji: '🍖',
    ),
    MarketplaceCategory(
      id: 'bakery',
      name: 'Bakery',
      urduName: 'مٹھائی اور بیکری',
      icon: Icons.cake_rounded,
      accentColor: Color(0xFFEA580C),
      emoji: '🍰',
    ),
    MarketplaceCategory(
      id: 'produce',
      name: 'Fruits & Honey',
      urduName: 'تازہ پھل اور شہد',
      icon: Icons.eco_rounded,
      accentColor: Color(0xFF16A34A),
      emoji: '🍎',
    ),
    MarketplaceCategory(
      id: 'electronics',
      name: 'Electronics',
      urduName: 'موبائل و الیکٹرانکس',
      icon: Icons.devices_other_rounded,
      accentColor: Color(0xFF2563EB),
      emoji: '📱',
    ),
    MarketplaceCategory(
      id: 'fashion',
      name: 'Fashion',
      urduName: 'کپڑے اور چپل',
      icon: Icons.checkroom_rounded,
      accentColor: Color(0xFF7C3AED),
      emoji: '👞',
    ),
  ];

  // 12 Comprehensive Demo Stores in Batkhela
  static final List<DemoStore> stores = [
    // 1. Restaurant
    DemoStore(
      id: 'store-1',
      name: 'Khyber Shinwari Tikka & Karahi',
      categoryId: 'restaurants',
      categoryName: 'Restaurants & BBQ',
      description: 'Authentic Mutton Karahi, Chapli Kabab, Namkeen Tikka & Hot Naan',
      address: 'Main GT Road, Near Bypass Chowk, Batkhela',
      rating: 4.9,
      reviewCount: 240,
      deliveryTime: '25-35 min',
      deliveryFee: 'Free Delivery',
      badges: ['Top Rated', 'Featured'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-101',
          vendorId: 'store-1',
          name: 'Shinwari Mutton Karahi (Full KG)',
          description: 'Prepared in pure lamb fat with fresh tomatoes and organic green chillies',
          price: 2400.0,
          discountPrice: 2150.0,
          category: 'Karahi Special',
          imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-102',
          vendorId: 'store-1',
          name: 'Peshawari Chapli Kabab (Per Piece)',
          description: 'Juicy spiced minced beef patties garnished with pomegranate seeds',
          price: 180.0,
          category: 'Kababs & BBQ',
          imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-103',
          vendorId: 'store-1',
          name: 'Dumba Namkeen Tikka Skewer',
          description: 'Salted tender mutton cuts charcoal grilled over wood embers',
          price: 650.0,
          discountPrice: 580.0,
          category: 'Kababs & BBQ',
          imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-104',
          vendorId: 'store-1',
          name: 'Kandahari Roghani Naan',
          description: 'Fresh tandoori naan with sesame seeds and butter glaze',
          price: 40.0,
          category: 'Tandoor',
          imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-105',
          vendorId: 'store-1',
          name: 'Special Chicken White Karahi (Half KG)',
          description: 'Creamy yogurt and black pepper mild chicken karahi',
          price: 1100.0,
          discountPrice: 990.0,
          category: 'Karahi Special',
          imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 2. Restaurant
    DemoStore(
      id: 'store-2',
      name: 'Batkhela BBQ House & Biryani',
      categoryId: 'restaurants',
      categoryName: 'Restaurants & BBQ',
      description: 'Charcoal BBQ skewers, Malai Boti, Seekh Kabab, and aromatic Chicken Biryani',
      address: 'Main Bazaar Road, Near Clock Tower, Batkhela',
      rating: 4.7,
      reviewCount: 165,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 40',
      badges: ['Popular BBQ'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-201',
          vendorId: 'store-2',
          name: 'Chicken Malai Boti Plate (8 Pcs)',
          description: 'Melt-in-mouth boneless chicken cubes marinated in rich fresh cream and spices',
          price: 680.0,
          discountPrice: 620.0,
          category: 'BBQ Special',
          imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-202',
          vendorId: 'store-2',
          name: 'Beef Seekh Kabab (4 Skewers)',
          description: 'Minced beef blended with fresh herbs and cooked over live coals',
          price: 520.0,
          category: 'BBQ Special',
          imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-203',
          vendorId: 'store-2',
          name: 'Special Malakand Chicken Biryani (Double)',
          description: 'Long grain spiced Basmati rice layered with succulent chicken pieces and raita',
          price: 450.0,
          discountPrice: 390.0,
          category: 'Rice & Biryani',
          imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-204',
          vendorId: 'store-2',
          name: 'Chilled Mint Raita & Fresh Salad Platter',
          description: 'Fresh cucumber, onions, tomatoes with refreshing mint yogurt dip',
          price: 100.0,
          category: 'Sides & Drinks',
          imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 3. Restaurant
    DemoStore(
      id: 'store-3',
      name: 'Malakand Food Point & Fast Food',
      categoryId: 'restaurants',
      categoryName: 'Restaurants & BBQ',
      description: 'Zinger burgers, Crispy Shawarma, Loaded Fries & Broast',
      address: 'College Road, Opp. Govt Degree College, Batkhela',
      rating: 4.6,
      reviewCount: 120,
      deliveryTime: '15-25 min',
      deliveryFee: 'PKR 50',
      badges: ['Fast Food'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-301',
          vendorId: 'store-3',
          name: 'Mighty Crispy Zinger Burger',
          description: 'Crispy fried chicken breast fillet with iceberg lettuce and spicy mayo in brioche bun',
          price: 420.0,
          discountPrice: 370.0,
          category: 'Burgers & Sandwiches',
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-302',
          vendorId: 'store-3',
          name: 'Batkhela Special Chicken Shawarma Wrap',
          description: 'Grilled spiced shredded chicken with garlic tahini sauce wrapped in pita bread',
          price: 220.0,
          category: 'Shawarma & Wraps',
          imageUrl: 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-303',
          vendorId: 'store-3',
          name: 'Loaded Cheesy Curly Fries',
          description: 'Golden curly potato fries seasoned with chaat masala, jalapeños, and warm cheddar sauce',
          price: 280.0,
          category: 'Sides & Fries',
          imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-304',
          vendorId: 'store-3',
          name: 'Chilled Chocolate Jamocha Shake',
          description: 'Thick creamy chocolate-coffee milkshake topped with whipped cream and cocoa drizzle',
          price: 350.0,
          discountPrice: 299.0,
          category: 'Cold Drinks & Shakes',
          imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-305',
          vendorId: 'store-3',
          name: 'Ice-Cold Pepsi & Sting Party Pack (4 Bottles)',
          description: '2x Chilled Pepsi 1.5L Jumbo + 2x Sting Berry Blast 500ml delivered ice-cold',
          price: 540.0,
          discountPrice: 480.0,
          category: 'Cold Drinks & Shakes',
          imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 4. Restaurant
    DemoStore(
      id: 'store-4',
      name: 'Peshawar Chapli Kabab House',
      categoryId: 'restaurants',
      categoryName: 'Restaurants & BBQ',
      description: 'Traditional fried chapli kababs with tandoori naan and green chutney',
      address: 'General Bus Stand, Batkhela',
      rating: 4.8,
      reviewCount: 190,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 30',
      badges: ['Desi Classic'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-401',
          vendorId: 'store-4',
          name: 'Special Jumbo Beef Chapli Kabab',
          description: 'Traditional heavy pan-fried spiced beef kabab served piping hot',
          price: 220.0,
          category: 'Chapli Special',
          imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-402',
          vendorId: 'store-4',
          name: 'Chicken Chapli Kabab (Per Piece)',
          description: 'Minced chicken patty cooked with fresh mint, coriander and roasted spices',
          price: 190.0,
          category: 'Chapli Special',
          imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 5. Grocery
    DemoStore(
      id: 'store-5',
      name: 'Swat Valley Super Mart',
      categoryId: 'grocery',
      categoryName: 'Fresh Grocery',
      description: 'Daily dairy, premium pulses, cooking oils, beverages, tea & household items',
      address: 'College Road, Batkhela',
      rating: 4.7,
      reviewCount: 180,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 50',
      badges: ['Fast Delivery', 'Superstore'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-501',
          vendorId: 'store-5',
          name: 'Super Basmati Rice (5 KG Pack)',
          description: 'Long grain extra fragrant Pakistani Basmati rice',
          price: 1650.0,
          discountPrice: 1499.0,
          category: 'Grains & Pulses',
          imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-502',
          vendorId: 'store-5',
          name: 'Dalda Premium Cooking Oil (5 Litre Tin)',
          description: 'Pure enriched vegetable oil for healthy family meals',
          price: 2750.0,
          discountPrice: 2620.0,
          category: 'Oils & Ghee',
          imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-503',
          vendorId: 'store-5',
          name: 'Farm Fresh Organic Eggs (Dozen)',
          description: 'Locally sourced fresh nutritious country eggs',
          price: 360.0,
          category: 'Dairy & Eggs',
          imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-504',
          vendorId: 'store-5',
          name: 'Tapal Danedar Black Tea (900g Family Pack)',
          description: 'Strong, aromatic blend of high quality tea leaves',
          price: 1350.0,
          category: 'Beverages & Tea',
          imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-505',
          vendorId: 'store-5',
          name: 'Fine Wheat Chakki Atta (10 KG Bag)',
          description: '100% whole grain stone ground wheat flour',
          price: 1320.0,
          discountPrice: 1250.0,
          category: 'Flour & Bakery',
          imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 6. Grocery
    DemoStore(
      id: 'store-6',
      name: 'Batkhela Fresh Mart & Wholesale',
      categoryId: 'grocery',
      categoryName: 'Fresh Grocery',
      description: 'Wholesale grains, spices, cleaning supplies, and milk cartons',
      address: 'Main Bazaar Road, Batkhela',
      rating: 4.8,
      reviewCount: 210,
      deliveryTime: '25-35 min',
      deliveryFee: 'PKR 40',
      badges: ['Wholesale Deals'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-601',
          vendorId: 'store-6',
          name: 'Nestle MilkPak UHT 1L (Pack of 6)',
          description: 'Pure, standardized full cream milk cartons',
          price: 1740.0,
          discountPrice: 1650.0,
          category: 'Dairy',
          imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-602',
          vendorId: 'store-6',
          name: 'National Spices Family Recipe Bundle',
          description: 'Biryani, Karahi, Haleem, and Chaat Masala pack of 4',
          price: 480.0,
          category: 'Spices & Masala',
          imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-603',
          vendorId: 'store-6',
          name: 'Refined White Sugar (5 KG Bag)',
          description: 'Premium crystal white refined Pakistani sugar',
          price: 750.0,
          category: 'Pantry Essentials',
          imageUrl: 'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 7. Pharmacy
    DemoStore(
      id: 'store-7',
      name: 'Batkhela Central Pharmacy & Surgical',
      categoryId: 'pharmacy',
      categoryName: 'Pharmacy & Health',
      description: 'Prescription medicines, infant nutrition, personal care & emergency medical kits',
      address: 'Civil Hospital Road, Batkhela',
      rating: 4.9,
      reviewCount: 310,
      deliveryTime: '15-20 min',
      deliveryFee: 'PKR 30',
      badges: ['24/7 Available', 'Express 20 Min'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-701',
          vendorId: 'store-7',
          name: 'Panadol Extra Tablets (Box of 20)',
          description: 'Paracetamol 500mg with caffeine for fast relief from pain and fever',
          price: 380.0,
          category: 'Pain Relief & Fever',
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-702',
          vendorId: 'store-7',
          name: 'First Aid Emergency Care Kit',
          description: 'Bandages, antiseptic pyodine, gauze rolls, scissors and medical tape',
          price: 850.0,
          discountPrice: 750.0,
          category: 'First Aid & Surgical',
          imageUrl: 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-703',
          vendorId: 'store-7',
          name: 'Brufen Suspension 100mg Syrup',
          description: 'Anti-inflammatory syrup for children and fever control',
          price: 120.0,
          category: 'Syrups & Suspensions',
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-704',
          vendorId: 'store-7',
          name: 'Surgical Protective Face Masks (Pack of 50)',
          description: '3-Ply breathable bacterial filter face masks with ear loops',
          price: 250.0,
          category: 'Hygiene & Wellness',
          imageUrl: 'https://images.unsplash.com/photo-1586942593568-29361efcd571?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 8. Pharmacy
    DemoStore(
      id: 'store-8',
      name: 'City Care Pharmacy Batkhela',
      categoryId: 'pharmacy',
      categoryName: 'Pharmacy & Health',
      description: 'Baby care diapers, multivitamins, thermometers & diagnostic supplies',
      address: 'Main Bazaar Road, Opp. GPO, Batkhela',
      rating: 4.8,
      reviewCount: 140,
      deliveryTime: '15-25 min',
      deliveryFee: 'PKR 40',
      badges: ['Reliable Care'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1576602976047-174e57a47881?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-801',
          vendorId: 'store-8',
          name: 'Multivitamin & Zinc Dietary Booster (30 Tabs)',
          description: 'Daily immunity supporting essential minerals and vitamin complex',
          price: 650.0,
          discountPrice: 580.0,
          category: 'Vitamins & Supplements',
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-802',
          vendorId: 'store-8',
          name: 'Instant Digital Body Thermometer',
          description: 'Accurate 10-second fast LCD temperature reading',
          price: 490.0,
          category: 'Diagnostics',
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 9. Sweets & Bakers
    DemoStore(
      id: 'store-9',
      name: 'Malakand Sweets & Bakers',
      categoryId: 'bakery',
      categoryName: 'Bakery & Sweets',
      description: 'Traditional Batkhela Gulab Jamun, Pistachio Barfi, Rasmalai, and fresh cream cakes',
      address: 'Thana Road, Batkhela',
      rating: 4.9,
      reviewCount: 280,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 40',
      badges: ['Batkhela Special', 'Must Try'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-901',
          vendorId: 'store-9',
          name: 'Fresh Batkhela Gulab Jamun (1 KG Box)',
          description: 'Warm soft milk dumplings soaked in cardamom saffron sugar syrup',
          price: 850.0,
          discountPrice: 780.0,
          category: 'Traditional Sweets',
          imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-902',
          vendorId: 'store-9',
          name: 'Traditional Khoya Peda & Barfi Mix (1 KG)',
          description: 'Pure desi ghee condensed milk sweet garnished with silver leaf & pistachios',
          price: 950.0,
          category: 'Traditional Sweets',
          imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-903',
          vendorId: 'store-9',
          name: 'Belgian Chocolate Fudge Cake (2 Lbs)',
          description: 'Rich moist chocolate sponge layered with creamy dark fudge icing',
          price: 1400.0,
          discountPrice: 1250.0,
          category: 'Cakes & Pastries',
          imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 10. Sweets & Bakers
    DemoStore(
      id: 'store-10',
      name: 'Batkhela Royal Sweet Palace',
      categoryId: 'bakery',
      categoryName: 'Bakery & Sweets',
      description: 'Hot Jalebi, crispy samosas, bakery biscuits, rusks & fresh tea loaf',
      address: 'Main GT Road, Batkhela',
      rating: 4.7,
      reviewCount: 175,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 30',
      badges: ['Freshly Baked'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1001',
          vendorId: 'store-10',
          name: 'Crispy Desi Ghee Jalebi (Half KG)',
          description: 'Hot spiral saffron sugar syrup pretzel sweet made fresh on order',
          price: 450.0,
          category: 'Traditional Sweets',
          imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1002',
          vendorId: 'store-10',
          name: 'Almond & Pistachio Nan Khatai (500g)',
          description: 'Traditional crumbly butter shortbread cookies with toasted almonds',
          price: 420.0,
          category: 'Bakery Biscuits',
          imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 11. Produce / Fruits & Veg
    DemoStore(
      id: 'store-11',
      name: 'Fresh Sabzi & Fruits Mandi Batkhela',
      categoryId: 'produce',
      categoryName: 'Fruits & Vegetables',
      description: 'Daily fresh Swat apples, juicy mangoes, seasonal farm tomatoes, potatoes, onions & herbs',
      address: 'Sabzi Mandi Road, Near River Bridge, Batkhela',
      rating: 4.8,
      reviewCount: 220,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 40',
      badges: ['100% Farm Fresh', 'Organic Sourced'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1101',
          vendorId: 'store-11',
          name: 'Crisp Swat Red Apples (1 KG)',
          description: 'Sweet, juicy organic mountain apples picked fresh from Swat orchards',
          price: 280.0,
          discountPrice: 240.0,
          category: 'Fresh Fruits',
          imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1102',
          vendorId: 'store-11',
          name: 'Sweet Chaunsa Mangoes (1 KG)',
          description: 'Aromatic, rich golden pulp premium summer mangoes',
          price: 320.0,
          discountPrice: 280.0,
          category: 'Fresh Fruits',
          imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1103',
          vendorId: 'store-11',
          name: 'Fresh Batkhela Farm Tomatoes (2 KG Basket)',
          description: 'Firm, ripe local red salad tomatoes for daily cooking',
          price: 180.0,
          category: 'Fresh Vegetables',
          imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1104',
          vendorId: 'store-11',
          name: 'Organic Red Skin Potatoes (5 KG Bag)',
          description: 'Freshly harvested dirt-free cooking potatoes',
          price: 340.0,
          category: 'Fresh Vegetables',
          imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 12. General Store
    DemoStore(
      id: 'store-12',
      name: 'Main Bazaar General Store',
      categoryId: 'general',
      categoryName: 'General Stores',
      description: 'Household laundry detergents, shampoo, soaps, dishwash, and daily utilities',
      address: 'Main Bazaar Road, Near Post Office, Batkhela',
      rating: 4.6,
      reviewCount: 130,
      deliveryTime: '20-35 min',
      deliveryFee: 'PKR 40',
      badges: ['Everyday Essentials'],
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=600&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1201',
          vendorId: 'store-12',
          name: 'Surf Excel Quick Wash Powder (1 KG)',
          description: 'Advanced stain removal washing powder with refreshing fragrance',
          price: 620.0,
          discountPrice: 560.0,
          category: 'Laundry & Cleaning',
          imageUrl: 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1202',
          vendorId: 'store-12',
          name: 'Lifebuoy Antibacterial Handwash (250ml Pump)',
          description: 'Complete germ protection liquid hand soap with moisture lock',
          price: 290.0,
          category: 'Personal Care',
          imageUrl: 'https://images.unsplash.com/photo-1584483766114-2cea6facdf57?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1203',
          vendorId: 'store-12',
          name: 'Dove Daily Moisture Care Shampoo (360ml)',
          description: 'Nourishing silk protein shampoo for smooth and healthy hair',
          price: 680.0,
          discountPrice: 599.0,
          category: 'Personal Care',
          imageUrl: 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1204',
          vendorId: 'store-12',
          name: 'Lemon Max Dishwash Liquid (750ml Bottle)',
          description: 'Concentrated lemon grease cutter for sparkling clean kitchenware',
          price: 350.0,
          category: 'Laundry & Cleaning',
          imageUrl: 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 13. Mobile & Tech
    DemoStore(
      id: 'store-13',
      name: 'Malakand Mobile & Electronics Hub',
      categoryId: 'electronics',
      categoryName: 'Mobile & Tech',
      description: 'Fast chargers, wireless earbuds, power banks, smartwatches & LED solar lights',
      address: 'Main Bazaar Road, Opp. Allied Bank, Batkhela',
      rating: 4.9,
      reviewCount: 195,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free Delivery',
      badges: ['Genuine Warranty', 'Top Tech'],
      isOpen: true,
      ownerName: 'Tariq Mahmood Khan',
      phone: '+92 346 9988776',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1301',
          vendorId: 'store-13',
          name: '20,000mAh Fast Charge Power Bank (22.5W PD)',
          description: 'Dual USB + Type-C super-fast charging power bank with digital LED battery display',
          price: 4200.0,
          discountPrice: 3650.0,
          category: 'Power Banks & Chargers',
          imageUrl: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1302',
          vendorId: 'store-13',
          name: 'ANC Pro Wireless Bluetooth Earbuds',
          description: 'Active noise cancellation, crystal clear mic & 30-hour charging case battery life',
          price: 3500.0,
          discountPrice: 2890.0,
          category: 'Audio & Earbuds',
          imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1303',
          vendorId: 'store-13',
          name: 'Super Fast 45W Type-C Wall Adapter + Cable',
          description: 'Original high-speed PD adapter compatible with Samsung, iPhone & Xiaomi',
          price: 1850.0,
          discountPrice: 1550.0,
          category: 'Power Banks & Chargers',
          imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1304',
          vendorId: 'store-13',
          name: 'Ultra Series 9 AMOLED Smart Watch',
          description: 'Bluetooth calling, heart rate monitor, prayer time reminders & waterproof strap',
          price: 4800.0,
          discountPrice: 3990.0,
          category: 'Smart Watches',
          imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 14. Chappal & Traditional Fabrics
    DemoStore(
      id: 'store-14',
      name: 'Khyber Chappal & Traditional Fabrics',
      categoryId: 'fashion',
      categoryName: 'Chappal & Fabrics',
      description: 'Handmade Peshawari & Charsadda leather chappals, Swati woolen shawls & unstitched suits',
      address: 'Chappal Market, Main Bazaar, Batkhela',
      rating: 4.8,
      reviewCount: 160,
      deliveryTime: '25-40 min',
      deliveryFee: 'PKR 50',
      badges: ['Handmade Leather', 'Pashtun Heritage'],
      isOpen: true,
      ownerName: 'Haji Gulzar Ahmad',
      phone: '+92 332 5544332',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&auto=format&fit=crop&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1401',
          vendorId: 'store-14',
          name: 'Handmade Zalmi Peshawari Leather Chappal',
          description: '100% pure cow leather hand-stitched double-sole traditional footwear with tire grip',
          price: 3800.0,
          discountPrice: 3290.0,
          category: 'Peshawari Chappals',
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1402',
          vendorId: 'store-14',
          name: 'Premium Men Unstitched Wash & Wear Suit (4.5m)',
          description: 'Wrinkle-free breathable fabric ideal for all seasons in classic off-white & navy',
          price: 2950.0,
          discountPrice: 2550.0,
          category: 'Unstitched Fabrics',
          imageUrl: 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1403',
          vendorId: 'store-14',
          name: 'Authentic Islampur Swati Handwoven Woolen Shawl',
          description: 'Warm, soft pure wool men chaddar woven by master artisans of Swat valley',
          price: 4500.0,
          discountPrice: 3900.0,
          category: 'Swati Shawls & Pakol',
          imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 15. Restaurant - Pulao & Sajji
    DemoStore(
      id: 'store-15',
      name: 'Al-Madina Bannu Beef Pulao & Sajji',
      categoryId: 'restaurants',
      categoryName: 'Restaurants & BBQ',
      description: 'Famous spiced Bannu Beef Pulao, Kabuli Afghani Pulao, Whole Roasted Chicken Sajji & Kahwa',
      address: 'Bypass Road, Near NADRA Office, Batkhela',
      rating: 4.9,
      reviewCount: 315,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free Delivery',
      badges: ['Bestseller Pulao', 'Hot & Fresh'],
      isOpen: true,
      ownerName: 'Ustad Rehman Ullah',
      phone: '+92 313 9001199',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1501',
          vendorId: 'store-15',
          name: 'Special Bannu Beef Yakhni Pulao (Full Plate)',
          description: 'Slow-cooked tender beef shank chunks over aromatic bone-broth sella rice',
          price: 550.0,
          discountPrice: 490.0,
          category: 'Traditional Pulao',
          imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1502',
          vendorId: 'store-15',
          name: 'Whole Charcoal Roasted Chicken Sajji with Rice',
          description: 'Marinated whole organic chicken slow-roasted over wood fire served on masala rice',
          price: 1650.0,
          discountPrice: 1480.0,
          category: 'Sajji & Roast',
          imageUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1503',
          vendorId: 'store-15',
          name: 'Kabuli Afghani Mutton Pulao (With Raisins & Carrots)',
          description: 'Authentic Kabuli rice topped with caramelized sweet carrots, almonds and mutton shank',
          price: 950.0,
          discountPrice: 880.0,
          category: 'Traditional Pulao',
          imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 16. Dry Fruits & Organic Honey
    DemoStore(
      id: 'store-16',
      name: 'Swat Dry Fruits & Sidr Honey House',
      categoryId: 'produce',
      categoryName: 'Fruits & Dry Fruits',
      description: '100% pure Malakand Beri (Sidr) mountain honey, roasted almonds, walnuts, pistachios & dates',
      address: 'Main GT Road, Near Clock Tower, Batkhela',
      rating: 4.9,
      reviewCount: 205,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 40',
      badges: ['100% Pure Organic', 'Gift Packs'],
      isOpen: true,
      ownerName: 'Haji Fazal Subhan',
      phone: '+92 300 5987612',
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=600&auto=format&fit=crop&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80',
      products: [
        Product(
          id: 'p-1601',
          vendorId: 'store-16',
          name: 'Pure Malakand Wild Beri (Sidr) Honey (1 KG Jar)',
          description: 'Unprocessed, raw organic Sidr mountain honey harvested from local Malakand apiaries',
          price: 2600.0,
          discountPrice: 2290.0,
          category: 'Organic Honey',
          imageUrl: 'https://images.unsplash.com/photo-1587049352847-4a222e784d38?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1602',
          vendorId: 'store-16',
          name: 'Premium California & Swati Almonds Giri (500g)',
          description: 'Crunchy, sweet-kernel supreme quality peeled almonds rich in vitamin E',
          price: 1650.0,
          discountPrice: 1490.0,
          category: 'Dry Fruits & Nuts',
          imageUrl: 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1603',
          vendorId: 'store-16',
          name: 'Kaghazi Swat Walnuts / Akhrot (1 KG Pack)',
          description: 'Thin-shelled easy-crack mountain walnuts loaded with omega-3 nutrition',
          price: 1200.0,
          discountPrice: 1050.0,
          category: 'Dry Fruits & Nuts',
          imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1604',
          vendorId: 'store-16',
          name: 'Royal Winter Dry Fruit Gift Box (1.5 KG Assorted)',
          description: 'Luxury gift box with pistachios, cashews, almonds, walnuts, figs and dried apricots',
          price: 4200.0,
          discountPrice: 3750.0,
          category: 'Gift Boxes',
          imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
  ];

  // Helper getters
  static List<Product> get allFeaturedProducts {
    final list = <Product>[];
    for (final s in stores) {
      list.addAll(s.products);
    }
    return list;
  }

  /// Smart store filter supporting Featured, Grocery, Medicine, Fast Food, Cold Drinks, BBQ, etc.
  static List<DemoStore> storesForCategory(String categoryId) {
    if (categoryId == 'all') return stores;
    if (categoryId == 'fastfood') {
      return stores.where((s) =>
          s.id == 'store-3' ||
          s.badges.any((b) => b.toLowerCase().contains('fast')) ||
          s.description.toLowerCase().contains('burger') ||
          s.categoryId == 'restaurants').toList();
    }
    if (categoryId == 'colddrinks') {
      return stores.where((s) =>
          s.id == 'store-3' ||
          s.categoryId == 'bakery' ||
          s.categoryId == 'grocery' ||
          s.products.any((p) =>
              (p.category ?? '').toLowerCase().contains('drink') ||
              p.name.toLowerCase().contains('shake') ||
              p.name.toLowerCase().contains('pepsi') ||
              p.name.toLowerCase().contains('milk'))).toList();
    }
    return stores.where((s) => s.categoryId == categoryId).toList();
  }

  /// Smart product filter for Popular Picks & Category Carousels
  static List<Product> productsForCategory(String categoryId) {
    final all = allFeaturedProducts;
    if (categoryId == 'all') {
      // Curate top popular picks across Fast Food, Cold Drinks, BBQ, Grocery, Medicine
      final priorityIds = [
        'p-301', // Mighty Crispy Zinger Burger
        'p-303', // Loaded Cheesy Curly Fries
        'p-304', // Chilled Chocolate Jamocha Shake
        'p-101', // Shinwari Mutton Karahi
        'p-501', // Basmati Rice / Grocery
        'p-701', // Panadol / Medicine
        'p-305', // Ice-Cold Pepsi & Sting Pack
        'p-201', // Chicken Malai Boti
        'p-901', // Gulab Jamun
        'p-1601', // Pure Sidr Honey
      ];
      final curated = <Product>[];
      for (final pid in priorityIds) {
        final match = all.where((p) => p.id == pid);
        if (match.isNotEmpty) curated.add(match.first);
      }
      for (final p in all) {
        if (!curated.any((c) => c.id == p.id)) {
          curated.add(p);
        }
      }
      return curated;
    }
    if (categoryId == 'fastfood') {
      final matches = all.where((p) {
        final text = '${p.name} ${p.category} ${p.description ?? ''}'.toLowerCase();
        return text.contains('burger') ||
            text.contains('fries') ||
            text.contains('shawarma') ||
            text.contains('kabab') ||
            text.contains('tikka') ||
            p.vendorId == 'store-3';
      }).toList();
      return matches.isNotEmpty ? matches : all;
    }
    if (categoryId == 'colddrinks') {
      final matches = all.where((p) {
        final text = '${p.name} ${p.category} ${p.description ?? ''}'.toLowerCase();
        return text.contains('drink') ||
            text.contains('shake') ||
            text.contains('pepsi') ||
            text.contains('sting') ||
            text.contains('milk') ||
            text.contains('tea') ||
            text.contains('honey') ||
            text.contains('raita');
      }).toList();
      return matches.isNotEmpty ? matches : all;
    }
    final catStores = storesForCategory(categoryId).map((s) => s.id).toSet();
    final filtered = all.where((p) => catStores.contains(p.vendorId)).toList();
    return filtered.isNotEmpty ? filtered : all;
  }

  static void addPlacedOrder(MarketplaceOrder order) {
    initialOrders.insert(0, order);
  }

  // Realistic Multi-State Customer Orders
  static final List<MarketplaceOrder> initialOrders = [
    // 1. Active Out for Delivery
    MarketplaceOrder(
      id: 'ORD-1042',
      orderNumber: 1042,
      customerId: 'CUST-01',
      vendorId: 'store-1',
      subtotal: 2150.0,
      deliveryFee: 0.0,
      platformFee: 30.0,
      totalAmount: 2180.0,
      status: OrderStatus.outForDelivery,
      deliveryAddress: 'Main Bazaar Road, Near GPO, Batkhela',
      customerNotes: 'Please call when rider arrives near GPO clock tower.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      items: const [
        OrderItem(
          id: 'oi-1',
          orderId: 'ORD-1042',
          productName: 'Shinwari Mutton Karahi (Full KG)',
          unitPrice: 2150.0,
          quantity: 1,
          totalPrice: 2150.0,
        ),
      ],
    ),

    // 2. Preparing in Kitchen
    MarketplaceOrder(
      id: 'ORD-1040',
      orderNumber: 1040,
      customerId: 'CUST-01',
      vendorId: 'store-5',
      subtotal: 1650.0,
      deliveryFee: 50.0,
      platformFee: 20.0,
      totalAmount: 1720.0,
      status: OrderStatus.preparing,
      deliveryAddress: 'Degree College Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      items: const [
        OrderItem(
          id: 'oi-2',
          orderId: 'ORD-1040',
          productName: 'Super Basmati Rice (5 KG Pack)',
          unitPrice: 1499.0,
          quantity: 1,
          totalPrice: 1499.0,
        ),
      ],
    ),

    // 3. Ready for Rider Pickup
    MarketplaceOrder(
      id: 'ORD-1038',
      orderNumber: 1038,
      customerId: 'CUST-01',
      vendorId: 'store-7',
      subtotal: 750.0,
      deliveryFee: 30.0,
      platformFee: 20.0,
      totalAmount: 800.0,
      status: OrderStatus.readyForPickup,
      deliveryAddress: 'Civil Hospital Colony, House #12, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      items: const [
        OrderItem(
          id: 'oi-3',
          orderId: 'ORD-1038',
          productName: 'First Aid Emergency Care Kit',
          unitPrice: 750.0,
          quantity: 1,
          totalPrice: 750.0,
        ),
      ],
    ),

    // 4. Delivered Yesterday
    MarketplaceOrder(
      id: 'ORD-1035',
      orderNumber: 1035,
      customerId: 'CUST-01',
      vendorId: 'store-9',
      subtotal: 780.0,
      deliveryFee: 40.0,
      platformFee: 20.0,
      totalAmount: 840.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'Thana Road, Near Bridge, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      items: const [
        OrderItem(
          id: 'oi-4',
          orderId: 'ORD-1035',
          productName: 'Fresh Batkhela Gulab Jamun (1 KG Box)',
          unitPrice: 780.0,
          quantity: 1,
          totalPrice: 780.0,
        ),
      ],
    ),

    // 5. Delivered Past Trip
    MarketplaceOrder(
      id: 'ORD-1029',
      orderNumber: 1029,
      customerId: 'CUST-01',
      vendorId: 'store-11',
      subtotal: 520.0,
      deliveryFee: 40.0,
      platformFee: 20.0,
      totalAmount: 580.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'Zafar Park Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      items: const [
        OrderItem(
          id: 'oi-5',
          orderId: 'ORD-1029',
          productName: 'Crisp Swat Red Apples (1 KG)',
          unitPrice: 240.0,
          quantity: 1,
          totalPrice: 240.0,
        ),
        OrderItem(
          id: 'oi-6',
          orderId: 'ORD-1029',
          productName: 'Sweet Chaunsa Mangoes (1 KG)',
          unitPrice: 280.0,
          quantity: 1,
          totalPrice: 280.0,
        ),
      ],
    ),
  ];

  static List<MarketplaceOrder> get demoOrders => initialOrders;
}
