import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

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
      name: 'Fruits & Sabzi',
      urduName: 'تازہ پھل اور سبزیاں',
      icon: Icons.eco_outlined,
      accentColor: Color(0xFF16A34A),
    ),
    MarketplaceCategory(
      id: 'bakery',
      name: 'Sweets & Bakery',
      urduName: 'مٹھائی اور نان بائی',
      icon: Icons.cake_outlined,
      accentColor: Color(0xFFD97706),
    ),
    MarketplaceCategory(
      id: 'general',
      name: 'General & Mobile',
      urduName: 'جنرل اسٹور',
      icon: Icons.devices_other_outlined,
      accentColor: AppColors.indigo,
    ),
  ];

  static final List<DemoStore> stores = [
    DemoStore(
      id: 'store-1',
      name: 'Khyber Shinwari Tikka & Karahi',
      categoryId: 'restaurants',
      categoryName: 'Restaurants & BBQ',
      description: 'Authentic Mutton Karahi, Chapli Kabab, Namkeen Tikka & Hot Naan',
      address: 'Main GT Road, Near Bypass, Batkhela',
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
          description: 'Prepared in pure lamb fat with fresh tomatoes and green chillies',
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
          description: 'Salted mutton cuts charcoal grilled to tender perfection',
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
      ],
    ),
    DemoStore(
      id: 'store-2',
      name: 'Swat Valley Super Mart',
      categoryId: 'grocery',
      categoryName: 'Fresh Grocery',
      description: 'Daily dairy, premium pulses, cooking oils, beverages & household items',
      address: 'College Road, Batkhela',
      rating: 4.7,
      reviewCount: 180,
      deliveryTime: '20-30 min',
      deliveryFee: 'PKR 50',
      badges: ['Fast Delivery'],
      isOpen: true,
      products: [
        Product(
          id: 'p-201',
          vendorId: 'store-2',
          name: 'Super Basmati Rice (5 KG Pack)',
          description: 'Long grain aromatic Pakistani Basmati rice',
          price: 1650.0,
          discountPrice: 1499.0,
          category: 'Grains & Pulses',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-202',
          vendorId: 'store-2',
          name: 'Dalda Premium Cooking Oil (5 Litre Tin)',
          description: 'Pure enriched vegetable oil for healthy family meals',
          price: 2750.0,
          category: 'Oils & Ghee',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-203',
          vendorId: 'store-2',
          name: 'Farm Fresh Organic Eggs (Dozen)',
          description: 'Locally sourced fresh country eggs',
          price: 360.0,
          category: 'Dairy & Eggs',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
    DemoStore(
      id: 'store-3',
      name: 'Batkhela Central Pharmacy',
      categoryId: 'pharmacy',
      categoryName: 'Pharmacy & Health',
      description: 'Prescription medicines, baby care essentials, first aid & supplements',
      address: 'Hospital Road, Civil Hospital Chowk, Batkhela',
      rating: 4.8,
      reviewCount: 110,
      deliveryTime: '15-25 min',
      deliveryFee: 'PKR 40',
      badges: ['24/7 Verified'],
      isOpen: true,
      products: [
        Product(
          id: 'p-301',
          vendorId: 'store-3',
          name: 'First Aid Emergency Care Kit',
          description: 'Bandages, antiseptic solution, cotton pads, scissors & surgical tape',
          price: 850.0,
          discountPrice: 750.0,
          category: 'Healthcare',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-302',
          vendorId: 'store-3',
          name: 'Digital Blood Pressure Monitor',
          description: 'Accurate upper-arm automatic BP monitor with LED screen',
          price: 3200.0,
          discountPrice: 2890.0,
          category: 'Medical Devices',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-303',
          vendorId: 'store-3',
          name: 'Pediatric Formula & Baby Nutrition (400g)',
          description: 'Essential infant formula with vitamins and minerals',
          price: 1850.0,
          category: 'Baby Care',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
    DemoStore(
      id: 'store-4',
      name: 'Malakand Sweets & Bakers',
      categoryId: 'bakery',
      categoryName: 'Sweets & Bakery',
      description: 'Traditional Batkhela Gulab Jamun, Cham Cham, Barfi, Rusks & Birthday Cakes',
      address: 'Main Bazaar, Near Post Office, Batkhela',
      rating: 4.9,
      reviewCount: 310,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free Delivery',
      badges: ['Locals Favorite'],
      isOpen: true,
      products: [
        Product(
          id: 'p-401',
          vendorId: 'store-4',
          name: 'Fresh Batkhela Gulab Jamun (1 KG Box)',
          description: 'Served warm in fragrant cardamom sugar syrup',
          price: 780.0,
          category: 'Desi Sweets',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-402',
          vendorId: 'store-4',
          name: 'Traditional Khoya Peda & Barfi Mix',
          description: 'Pure whole milk mawa confectionery topped with pistachios',
          price: 950.0,
          discountPrice: 880.0,
          category: 'Desi Sweets',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-403',
          vendorId: 'store-4',
          name: 'Special Almond Crispy Rusks (Large Box)',
          description: 'Double baked crispy tea rusks with real crushed almonds',
          price: 320.0,
          category: 'Bakery Items',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
    DemoStore(
      id: 'store-5',
      name: 'Malakand Green Sabzi & Fruit Mandi',
      categoryId: 'produce',
      categoryName: 'Fruits & Sabzi',
      description: 'Direct farm produce: Swat apples, Malakand tomatoes, potatoes & greens',
      address: 'Sabzi Mandi Road, Batkhela',
      rating: 4.6,
      reviewCount: 95,
      deliveryTime: '20-35 min',
      deliveryFee: 'PKR 60',
      badges: ['Farm Fresh'],
      isOpen: true,
      products: [
        Product(
          id: 'p-501',
          vendorId: 'store-5',
          name: 'Crisp Swat Red Apples (1 KG)',
          description: 'Freshly harvested sweet and juicy mountain apples',
          price: 280.0,
          discountPrice: 240.0,
          category: 'Fruits',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        Product(
          id: 'p-502',
          vendorId: 'store-5',
          name: 'Fresh Batkhela Farm Tomatoes (2 KG Basket)',
          description: 'Ripe red tomatoes directly sourced from local farmers',
          price: 180.0,
          category: 'Vegetables',
          isAvailable: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
  ];

  static List<Product> get allFeaturedProducts {
    return stores.expand((s) => s.products).toList();
  }

  static final List<MarketplaceOrder> demoOrders = [
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
      deliveryAddress: 'Main Bazaar, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      items: const [
        OrderItem(
          id: 'item-1',
          orderId: 'ORD-7291',
          productName: 'Shinwari Mutton Karahi (Full KG)',
          unitPrice: 2150.0,
          quantity: 1,
          totalPrice: 2150.0,
        ),
      ],
    ),
    MarketplaceOrder(
      id: 'ORD-6510',
      orderNumber: 1042,
      customerId: 'CUST-01',
      vendorId: 'store-4',
      subtotal: 880.0,
      deliveryFee: 50.0,
      platformFee: 20.0,
      totalAmount: 950.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'College Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      items: const [
        OrderItem(
          id: 'item-2',
          orderId: 'ORD-6510',
          productName: 'Traditional Khoya Peda & Barfi Mix',
          unitPrice: 880.0,
          quantity: 1,
          totalPrice: 880.0,
        ),
      ],
    ),
  ];
}
