import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

/// Marketplace Promotional Banner Model
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

/// Marketplace Category Definition for Batkhela Local Commerce
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
      primaryColor: Color(0xFF0F766E),
      accentColor: Color(0xFF99F6E4),
      icon: Icons.eco,
    ),
    MarketplacePromoBanner(
      id: 'banner-4',
      title: '24/7 Essential Medicine Dispatch',
      subtitle: 'Prescription medicines and baby wellness essentials delivered within 20 minutes',
      tag: 'HEALTHCARE 24/7',
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
      products: [
        Product(
          id: 'p-101',
          vendorId: 'store-1',
          name: 'Shinwari Mutton Karahi (Full KG)',
          description: 'Prepared in pure lamb fat with fresh tomatoes and organic green chillies',
          price: 2400.0,
          discountPrice: 2150.0,
          category: 'Karahi Special',
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
      products: [
        Product(
          id: 'p-201',
          vendorId: 'store-2',
          name: 'Chicken Malai Boti Plate (8 Pcs)',
          description: 'Melt-in-mouth boneless chicken cubes marinated in rich fresh cream and spices',
          price: 680.0,
          discountPrice: 620.0,
          category: 'BBQ Special',
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
      products: [
        Product(
          id: 'p-301',
          vendorId: 'store-3',
          name: 'Mighty Crispy Zinger Burger',
          description: 'Crispy fried chicken breast fillet with iceberg lettuce and spicy mayo in brioche bun',
          price: 420.0,
          discountPrice: 370.0,
          category: 'Burgers & Sandwiches',
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
      products: [
        Product(
          id: 'p-401',
          vendorId: 'store-4',
          name: 'Special Jumbo Beef Chapli Kabab',
          description: 'Traditional heavy pan-fried spiced beef kabab served piping hot',
          price: 220.0,
          category: 'Chapli Special',
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
      products: [
        Product(
          id: 'p-501',
          vendorId: 'store-5',
          name: 'Super Basmati Rice (5 KG Pack)',
          description: 'Long grain extra fragrant Pakistani Basmati rice',
          price: 1650.0,
          discountPrice: 1499.0,
          category: 'Grains & Pulses',
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
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-504',
          vendorId: 'store-5',
          name: 'Tapal Danedar Black Tea (900g Family Pack)',
          description: 'Strong blend aromatic black tea granules for morning chai',
          price: 1350.0,
          category: 'Beverages & Tea',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 6. Grocery
    DemoStore(
      id: 'store-6',
      name: 'Batkhela Fresh Mart & Essentials',
      categoryId: 'grocery',
      categoryName: 'Fresh Grocery',
      description: 'Packaged dairy, spices, cleaning products, flour & snacks',
      address: 'Main Bazaar Road, Near GPO, Batkhela',
      rating: 4.8,
      reviewCount: 145,
      deliveryTime: '15-25 min',
      deliveryFee: 'PKR 40',
      badges: ['Reliable Mart'],
      isOpen: true,
      products: [
        Product(
          id: 'p-601',
          vendorId: 'store-6',
          name: 'Nestle MilkPak 1L (Pack of 6)',
          description: 'UHT treated whole milk with essential vitamins',
          price: 1680.0,
          discountPrice: 1560.0,
          category: 'Dairy & Milk',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-602',
          vendorId: 'store-6',
          name: 'Chakki Fresh Atta Flour (10 KG Bag)',
          description: 'Stone grounded whole wheat flour with natural fiber',
          price: 1380.0,
          category: 'Flour & Grains',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-603',
          vendorId: 'store-6',
          name: 'National Spices Family Biryani Box (Pack of 3)',
          description: 'Pre-mixed authentic Pakistani spice blend for biryani',
          price: 360.0,
          category: 'Spices & Seasoning',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 7. Pharmacy
    DemoStore(
      id: 'store-7',
      name: 'Batkhela Central Pharmacy',
      categoryId: 'pharmacy',
      categoryName: 'Pharmacy & Health',
      description: 'Prescription medicines, baby care essentials, first aid, supplements & monitors',
      address: 'Hospital Road, Civil Hospital Chowk, Batkhela',
      rating: 4.9,
      reviewCount: 210,
      deliveryTime: '15-20 min',
      deliveryFee: 'PKR 30',
      badges: ['24/7 Verified', 'Express Meds'],
      isOpen: true,
      products: [
        Product(
          id: 'p-701',
          vendorId: 'store-7',
          name: 'First Aid Emergency Care Kit',
          description: 'Bandages, antiseptic solution, cotton pads, scissors & surgical tape',
          price: 850.0,
          discountPrice: 750.0,
          category: 'First Aid',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-702',
          vendorId: 'store-7',
          name: 'Digital Blood Pressure Monitor',
          description: 'Accurate upper-arm automatic BP monitor with large LED display',
          price: 3200.0,
          discountPrice: 2890.0,
          category: 'Medical Devices',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-703',
          vendorId: 'store-7',
          name: 'Panadol Extra Tablets (Box of 20)',
          description: 'Effective relief for headache, body pain, and fever reduction',
          price: 160.0,
          category: 'Medicines',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-704',
          vendorId: 'store-7',
          name: 'Infant Baby Diapers (Size 3 - Pack of 44)',
          description: 'Ultra absorbent soft leakage protection diapers for toddlers',
          price: 1750.0,
          discountPrice: 1599.0,
          category: 'Baby Care',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 8. Pharmacy
    DemoStore(
      id: 'store-8',
      name: 'City Care Pharmacy & Medical Store',
      categoryId: 'pharmacy',
      categoryName: 'Pharmacy & Health',
      description: 'Vitamins, supplements, skin care, thermometer & diabetes care products',
      address: 'Zafar Park Road, Batkhela',
      rating: 4.7,
      reviewCount: 95,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 40',
      badges: ['Health Partner'],
      isOpen: true,
      products: [
        Product(
          id: 'p-801',
          vendorId: 'store-8',
          name: 'Accu-Chek Instant Blood Glucose Meter',
          description: 'Fast and reliable diabetes blood sugar testing machine with 10 strips',
          price: 2450.0,
          discountPrice: 2200.0,
          category: 'Medical Devices',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-802',
          vendorId: 'store-8',
          name: 'Multivitamin & Zinc Effervescent (20 Tabs)',
          description: 'Daily immunity booster with Vitamin C, D3 and Zinc',
          price: 680.0,
          category: 'Supplements',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 9. Bakery
    DemoStore(
      id: 'store-9',
      name: 'Malakand Sweets & Bakers',
      categoryId: 'bakery',
      categoryName: 'Bakery & Sweets',
      description: 'Traditional Batkhela Gulab Jamun, Cham Cham, Barfi, Rusks & Birthday Cakes',
      address: 'Main Bazaar, Near Post Office, Batkhela',
      rating: 4.9,
      reviewCount: 310,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free Delivery',
      badges: ['Locals Favorite', 'Fresh Baked'],
      isOpen: true,
      products: [
        Product(
          id: 'p-901',
          vendorId: 'store-9',
          name: 'Fresh Batkhela Gulab Jamun (1 KG Box)',
          description: 'Served warm in fragrant cardamom and saffron infused sugar syrup',
          price: 780.0,
          discountPrice: 720.0,
          category: 'Desi Sweets',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-902',
          vendorId: 'store-9',
          name: 'Traditional Khoya Peda & Barfi Mix (1 KG)',
          description: 'Pure whole milk mawa confectionery generously garnished with pistachios',
          price: 950.0,
          discountPrice: 880.0,
          category: 'Desi Sweets',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-903',
          vendorId: 'store-9',
          name: 'Special Almond Crispy Rusks (Large Box)',
          description: 'Double baked crispy tea rusks with real crunchy crushed almonds',
          price: 320.0,
          category: 'Bakery & Breads',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-904',
          vendorId: 'store-9',
          name: 'Belgium Chocolate Fudge Birthday Cake (2 Lbs)',
          description: 'Moist rich chocolate sponge frosted with smooth dark ganache',
          price: 1650.0,
          discountPrice: 1490.0,
          category: 'Cakes & Pastries',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 10. Bakery
    DemoStore(
      id: 'store-10',
      name: 'Batkhela Royal Sweet Palace',
      categoryId: 'bakery',
      categoryName: 'Bakery & Sweets',
      description: 'Hot Jalebi, Rasgulla, fresh morning croissants, puff pastry & fruit cakes',
      address: 'Thana Road, Batkhela',
      rating: 4.8,
      reviewCount: 140,
      deliveryTime: '20-25 min',
      deliveryFee: 'PKR 40',
      badges: ['Fresh Jalebi'],
      isOpen: true,
      products: [
        Product(
          id: 'p-1001',
          vendorId: 'store-10',
          name: 'Crispy Desi Ghee Jalebi (1 KG)',
          description: 'Golden spirals fried in pure desi ghee soaked in light cardamom syrup',
          price: 650.0,
          category: 'Desi Sweets',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1002',
          vendorId: 'store-10',
          name: 'Fresh English Fruit Cake Loaf (600g)',
          description: 'Soft butter cake loaded with candied cherries and dried raisins',
          price: 450.0,
          discountPrice: 390.0,
          category: 'Cakes & Pastries',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 11. Produce (Fruits & Vegetables)
    DemoStore(
      id: 'store-11',
      name: 'Fresh Sabzi & Fruits Mandi Batkhela',
      categoryId: 'produce',
      categoryName: 'Fruits & Vegetables',
      description: 'Direct farm harvest: Swat sweet apples, Malakand tomatoes, potatoes, onions & greens',
      address: 'Sabzi Mandi Road, Near Riverbank, Batkhela',
      rating: 4.8,
      reviewCount: 220,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 50',
      badges: ['Farm Fresh', 'Direct Harvest'],
      isOpen: true,
      products: [
        Product(
          id: 'p-1101',
          vendorId: 'store-11',
          name: 'Crisp Swat Red Apples (1 KG)',
          description: 'Freshly harvested crisp and juicy sweet mountain valley apples',
          price: 280.0,
          discountPrice: 240.0,
          category: 'Fresh Fruits',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1102',
          vendorId: 'store-11',
          name: 'Fresh Batkhela Farm Tomatoes (2 KG Basket)',
          description: 'Farm-fresh plump red ripe tomatoes from local growers',
          price: 220.0,
          discountPrice: 180.0,
          category: 'Fresh Vegetables',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1103',
          vendorId: 'store-11',
          name: 'Chakdara Farm Fresh Potatoes (5 KG Sack)',
          description: 'Clean medium-sized fresh cooking potatoes',
          price: 350.0,
          category: 'Fresh Vegetables',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1104',
          vendorId: 'store-11',
          name: 'Farm Fresh Golden Bananas (1 Dozen)',
          description: 'Naturally ripened sweet aromatic table bananas',
          price: 190.0,
          category: 'Fresh Fruits',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),

    // 12. General Store
    DemoStore(
      id: 'store-12',
      name: 'Main Bazaar General Store & Mobile Mart',
      categoryId: 'general',
      categoryName: 'General Stores',
      description: 'Mobile accessories, batteries, LED lights, stationeries & household gadgets',
      address: 'Main Bazaar Chowk, Batkhela',
      rating: 4.6,
      reviewCount: 88,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 50',
      badges: ['General Goods'],
      isOpen: true,
      products: [
        Product(
          id: 'p-1201',
          vendorId: 'store-12',
          name: 'Fast Charging USB-C Braided Cable (2M)',
          description: 'Durable nylon braided 65W fast power delivery data cable',
          price: 380.0,
          discountPrice: 320.0,
          category: 'Mobile Accessories',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-1202',
          vendorId: 'store-12',
          name: 'Rechargeable LED Emergency Torch Light',
          description: 'High beam long-lasting emergency battery lantern with USB charging',
          price: 850.0,
          category: 'Home & Electric',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
  ];

  static List<Product> get allFeaturedProducts {
    return stores.expand((s) => s.products).toList();
  }

  // Realistic Customer Orders covering all states
  static final List<MarketplaceOrder> demoOrders = [
    // 1. Active Out for Delivery
    MarketplaceOrder(
      id: 'ORD-7291',
      orderNumber: 1084,
      customerId: 'CUST-01',
      vendorId: 'store-1',
      subtotal: 2150.0,
      deliveryFee: 0.0,
      platformFee: 30.0,
      totalAmount: 2180.0,
      status: OrderStatus.outForDelivery,
      deliveryAddress: 'Main Bazaar, Near Clock Tower, Batkhela',
      customerNotes: 'Please ring the bell upon arrival, 2nd floor.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      items: const [
        OrderItem(
          id: 'item-101',
          orderId: 'ORD-7291',
          productName: 'Shinwari Mutton Karahi (Full KG)',
          unitPrice: 2150.0,
          quantity: 1,
          totalPrice: 2150.0,
        ),
        OrderItem(
          id: 'item-102',
          orderId: 'ORD-7291',
          productName: 'Kandahari Roghani Naan',
          unitPrice: 40.0,
          quantity: 2,
          totalPrice: 80.0,
        ),
      ],
    ),

    // 2. In Kitchen / Preparing
    MarketplaceOrder(
      id: 'ORD-7295',
      orderNumber: 1088,
      customerId: 'CUST-01',
      vendorId: 'store-2',
      subtotal: 620.0,
      deliveryFee: 40.0,
      platformFee: 20.0,
      totalAmount: 680.0,
      status: OrderStatus.preparing,
      deliveryAddress: 'Civil Hospital Colony, Batkhela',
      customerNotes: 'Send extra mint chutney and green chili.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      items: const [
        OrderItem(
          id: 'item-201',
          orderId: 'ORD-7295',
          productName: 'Chicken Malai Boti Plate (8 Pcs)',
          unitPrice: 620.0,
          quantity: 1,
          totalPrice: 620.0,
        ),
      ],
    ),

    // 3. Ready for Rider Pickup
    MarketplaceOrder(
      id: 'ORD-7298',
      orderNumber: 1091,
      customerId: 'CUST-01',
      vendorId: 'store-7',
      subtotal: 750.0,
      deliveryFee: 30.0,
      platformFee: 20.0,
      totalAmount: 800.0,
      status: OrderStatus.readyForPickup,
      deliveryAddress: 'Degree College Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      items: const [
        OrderItem(
          id: 'item-301',
          orderId: 'ORD-7298',
          productName: 'First Aid Emergency Care Kit',
          unitPrice: 750.0,
          quantity: 1,
          totalPrice: 750.0,
        ),
      ],
    ),

    // 4. Past Delivered Order
    MarketplaceOrder(
      id: 'ORD-6510',
      orderNumber: 1042,
      customerId: 'CUST-01',
      vendorId: 'store-9',
      subtotal: 880.0,
      deliveryFee: 0.0,
      platformFee: 20.0,
      totalAmount: 900.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'College Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      items: const [
        OrderItem(
          id: 'item-401',
          orderId: 'ORD-6510',
          productName: 'Traditional Khoya Peda & Barfi Mix (1 KG)',
          unitPrice: 880.0,
          quantity: 1,
          totalPrice: 880.0,
        ),
      ],
    ),

    // 5. Past Delivered Order
    MarketplaceOrder(
      id: 'ORD-6480',
      orderNumber: 1018,
      customerId: 'CUST-01',
      vendorId: 'store-5',
      subtotal: 1499.0,
      deliveryFee: 50.0,
      platformFee: 20.0,
      totalAmount: 1569.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'Main Bazaar Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      items: const [
        OrderItem(
          id: 'item-501',
          orderId: 'ORD-6480',
          productName: 'Super Basmati Rice (5 KG Pack)',
          unitPrice: 1499.0,
          quantity: 1,
          totalPrice: 1499.0,
        ),
      ],
    ),
  ];
}
