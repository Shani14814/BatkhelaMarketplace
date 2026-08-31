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

  const MarketplacePromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.ctaLabel,
    required this.primaryColor,
    required this.accentColor,
    required this.icon,
  });
}

/// Category Model for Customer Marketplace Navigation
class MarketplaceCategory {
  final String id;
  final String name;
  final String urduName;
  final IconData icon;
  final Color accentColor;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.urduName,
    required this.icon,
    required this.accentColor,
  });
}

/// Store Model with UI metadata for Customer Discovery
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
    this.products = const [],
  });
}

/// Centralized Local Demo Data for Batkhela Marketplace
class CustomerDemoData {
  static const String activeDeliveryAddress = 'Main Bazaar, Near Clock Tower, Batkhela';

  // Promotional Hero Banners
  static const List<MarketplacePromoBanner> promoBanners = [
    MarketplacePromoBanner(
      id: 'banner-1',
      title: 'Batkhela Local Express',
      subtitle: 'Free delivery on your first 3 orders across Batkhela & Thana bazaar',
      tag: 'SPECIAL PROMO',
      ctaLabel: 'Explore Stores',
      primaryColor: AppColors.primary,
      accentColor: AppColors.softCyan,
      icon: Icons.electric_moped,
    ),
    MarketplacePromoBanner(
      id: 'banner-2',
      title: 'Shinwari BBQ & Karahi Festival',
      subtitle: 'Flat 20% OFF on all Mutton & Chicken Karahi and BBQ platters this weekend',
      tag: 'WEEKEND SPECIAL',
      ctaLabel: 'Order Feast',
      primaryColor: AppColors.indigo,
      accentColor: AppColors.coral,
      icon: Icons.local_fire_department,
    ),
    MarketplacePromoBanner(
      id: 'banner-3',
      title: 'Farm Fresh Sabzi Mandi Deals',
      subtitle: 'Directly sourced from Malakand green farms with same-day express doorstep dispatch',
      tag: 'ORGANIC FRESH',
      ctaLabel: 'Shop Produce',
      primaryColor: Color(0xFF15803D),
      accentColor: Color(0xFF86EFAC),
      icon: Icons.eco,
    ),
    MarketplacePromoBanner(
      id: 'banner-4',
      title: 'Batkhela Central Pharmacy Care',
      subtitle: 'Genuine prescription medicines, vitamins & first-aid essentials delivered in 20 mins',
      tag: 'HEALTH FIRST',
      ctaLabel: 'Order Meds',
      primaryColor: Color(0xFFBE123C),
      accentColor: Color(0xFFFECDD3),
      icon: Icons.medical_services_outlined,
    ),
  ];

  // 6 Primary Categories
  static const List<MarketplaceCategory> categories = [
    MarketplaceCategory(
      id: 'all',
      name: 'All Categories',
      urduName: 'تمام',
      icon: Icons.grid_view_rounded,
      accentColor: AppColors.primary,
    ),
    MarketplaceCategory(
      id: 'restaurants',
      name: 'Restaurants & BBQ',
      urduName: 'ریستوران و تکہ',
      icon: Icons.restaurant_outlined,
      accentColor: AppColors.primary,
    ),
    MarketplaceCategory(
      id: 'grocery',
      name: 'Fresh Grocery',
      urduName: 'کریانہ و راشن',
      icon: Icons.shopping_basket_outlined,
      accentColor: AppColors.indigo,
    ),
    MarketplaceCategory(
      id: 'pharmacy',
      name: 'Pharmacy & Health',
      urduName: 'فارمیسی و ادویات',
      icon: Icons.local_pharmacy_outlined,
      accentColor: AppColors.coral,
    ),
    MarketplaceCategory(
      id: 'produce',
      name: 'Fruits & Vegetables',
      urduName: 'تازہ پھل اور سبزیاں',
      icon: Icons.eco_outlined,
      accentColor: Color(0xFF16A34A),
    ),
    MarketplaceCategory(
      id: 'bakery',
      name: 'Bakery & Sweets',
      urduName: 'مٹھائی اور بیکری',
      icon: Icons.cake_outlined,
      accentColor: Color(0xFFD97706),
    ),
    MarketplaceCategory(
      id: 'general',
      name: 'General Stores',
      urduName: 'جنرل اسٹور',
      icon: Icons.storefront_outlined,
      accentColor: AppColors.indigo,
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
          name: 'Loaded Cheesy Masala Fries',
          description: 'Golden potato fries seasoned with chaat masala, jalapeños, and warm cheddar sauce',
          price: 280.0,
          category: 'Sides & Fries',
          imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=400&auto=format&fit=crop&q=80',
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
