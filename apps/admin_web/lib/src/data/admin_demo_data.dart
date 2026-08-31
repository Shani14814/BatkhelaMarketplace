import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

// ----------------------------------------------------
// MODELS
// ----------------------------------------------------

enum ApprovalStatus { pending, approved, rejected }

class AdminCustomer {
  final String id;
  final String name;
  final String phone;
  final String area;
  final int totalOrders;
  final double totalSpend;
  final DateTime joinedAt;
  bool isActive;

  AdminCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.area,
    required this.totalOrders,
    required this.totalSpend,
    required this.joinedAt,
    this.isActive = true,
  });
}

class AdminVendorApplication {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String category;
  final String address;
  final double commissionRate;
  ApprovalStatus status;
  final DateTime appliedAt;

  AdminVendorApplication({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.category,
    required this.address,
    this.commissionRate = 10.0,
    this.status = ApprovalStatus.pending,
    required this.appliedAt,
  });
}

class AdminRiderApplication {
  final String id;
  final String riderName;
  final String phone;
  final String cnic;
  final String vehicleType;
  final String plateNumber;
  double rating;
  int completedTrips;
  ApprovalStatus status;
  final DateTime appliedAt;

  AdminRiderApplication({
    required this.id,
    required this.riderName,
    required this.phone,
    required this.cnic,
    required this.vehicleType,
    required this.plateNumber,
    this.rating = 4.9,
    this.completedTrips = 0,
    this.status = ApprovalStatus.pending,
    required this.appliedAt,
  });
}

class AdminCategory {
  final String id;
  String name;
  String iconName;
  int displayOrder;
  bool isEnabled;
  int productCount;

  AdminCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.displayOrder,
    this.isEnabled = true,
    required this.productCount,
  });
}

class AdminHomepageSection {
  final String id;
  String title;
  String sectionType;
  int displayOrder;
  bool isVisible;

  AdminHomepageSection({
    required this.id,
    required this.title,
    required this.sectionType,
    required this.displayOrder,
    this.isVisible = true,
  });
}

class AdminPromotionCampaign {
  final String id;
  String title;
  String storeName;
  String discountBannerText;
  DateTime startDate;
  DateTime endDate;
  bool isActive;

  AdminPromotionCampaign({
    required this.id,
    required this.title,
    required this.storeName,
    required this.discountBannerText,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });
}

class AdminCityRegion {
  final String id;
  String cityName;
  String province;
  bool isActive;
  int vendorCount;

  AdminCityRegion({
    required this.id,
    required this.cityName,
    required this.province,
    this.isActive = false,
    required this.vendorCount,
  });
}

class PlatformSettings {
  String marketplaceName;
  String defaultCity;
  String currency;
  double baseDeliveryFee;
  double platformCommissionPercent;
  String supportPhone;
  bool urduEnabled;

  PlatformSettings({
    this.marketplaceName = 'Batkhela Marketplace',
    this.defaultCity = 'Batkhela',
    this.currency = 'PKR',
    this.baseDeliveryFee = 100.0,
    this.platformCommissionPercent = 10.0,
    this.supportPhone = '+92 932 410000',
    this.urduEnabled = true,
  });
}

// ----------------------------------------------------
// CENTRALIZED ADMIN STATE CONTROLLER
// ----------------------------------------------------

class AdminDemoController extends ChangeNotifier {
  static final AdminDemoController instance = AdminDemoController._();
  AdminDemoController._();

  // 1. Overview KPIs
  int get totalCustomersCount => customers.length;
  int get activeVendorsCount => vendors.where((v) => v.status == ApprovalStatus.approved).length;
  int get activeRidersCount => riders.where((r) => r.status == ApprovalStatus.approved).length;
  int get todayOrdersCount => orders.length;
  double get todayPlatformGmv => orders.fold(0.0, (sum, o) => sum + o.totalAmount);
  double get todayPlatformRevenue => orders.fold(0.0, (sum, o) => sum + o.platformFee);
  int get pendingApprovalsCount =>
      vendors.where((v) => v.status == ApprovalStatus.pending).length +
      riders.where((r) => r.status == ApprovalStatus.pending).length;

  // 2. Customers List
  final List<AdminCustomer> customers = [
    AdminCustomer(
      id: 'CUST-001',
      name: 'Ahmed Khan',
      phone: '+92 300 9876543',
      area: 'Main Bazaar Road, Batkhela',
      totalOrders: 18,
      totalSpend: 24350.0,
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    AdminCustomer(
      id: 'CUST-002',
      name: 'Bilal Yousafzai',
      phone: '+92 345 1122334',
      area: 'Thana Road, Batkhela',
      totalOrders: 9,
      totalSpend: 11400.0,
      joinedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    AdminCustomer(
      id: 'CUST-003',
      name: 'Sardar Ali',
      phone: '+92 312 5566778',
      area: 'Civil Hospital Colony, Batkhela',
      totalOrders: 31,
      totalSpend: 42800.0,
      joinedAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    AdminCustomer(
      id: 'CUST-004',
      name: 'Zia-ur-Rehman',
      phone: '+92 333 9988776',
      area: 'Zafar Park Road, Batkhela',
      totalOrders: 5,
      totalSpend: 6200.0,
      joinedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  // 3. Vendors Directory & Approval Queue
  final List<AdminVendorApplication> vendors = [
    AdminVendorApplication(
      id: 'VEND-001',
      businessName: 'Khyber Shinwari Tikka & Karahi',
      ownerName: 'Haji Gulzar Khan',
      phone: '+92 345 9876543',
      category: 'Restaurants & BBQ',
      address: 'Main Grand Trunk Road, Batkhela',
      commissionRate: 10.0,
      status: ApprovalStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    AdminVendorApplication(
      id: 'VEND-002',
      businessName: 'Swat Valley Fresh Grocery',
      ownerName: 'Ihsan Ullah',
      phone: '+92 300 1234567',
      category: 'Fresh Grocery & Mart',
      address: 'Sabzi Mandi Road, Batkhela',
      commissionRate: 8.0,
      status: ApprovalStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AdminVendorApplication(
      id: 'VEND-003',
      businessName: 'Malakand Bakers & Sweets',
      ownerName: 'Rashid Mahmood',
      phone: '+92 312 3456789',
      category: 'Bakery & Sweets',
      address: 'College Road, Batkhela',
      commissionRate: 10.0,
      status: ApprovalStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AdminVendorApplication(
      id: 'VEND-004',
      businessName: 'Batkhela Central Pharmacy',
      ownerName: 'Dr. Tariq Shah',
      phone: '+92 334 8877665',
      category: 'Pharmacy & Health',
      address: 'Hospital Road, Batkhela',
      commissionRate: 7.5,
      status: ApprovalStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  // 4. Riders Fleet & Verification Queue
  final List<AdminRiderApplication> riders = [
    AdminRiderApplication(
      id: 'RIDER-001',
      riderName: 'Kamran Khan',
      phone: '+92 344 1122334',
      cnic: '15402-1234567-1',
      vehicleType: 'Honda CG 125',
      plateNumber: 'BK-M-2024-88',
      rating: 4.9,
      completedTrips: 280,
      status: ApprovalStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    AdminRiderApplication(
      id: 'RIDER-002',
      riderName: 'Usman Ali',
      phone: '+92 313 4455667',
      cnic: '15402-7654321-3',
      vehicleType: 'Yamaha YBR 125',
      plateNumber: 'BK-M-2024-102',
      rating: 4.8,
      completedTrips: 194,
      status: ApprovalStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    AdminRiderApplication(
      id: 'RIDER-003',
      riderName: 'Zubair Shah',
      phone: '+92 301 7788990',
      cnic: '15402-9988776-5',
      vehicleType: 'United 100cc',
      plateNumber: 'BK-M-2025-14',
      rating: 5.0,
      completedTrips: 0,
      status: ApprovalStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // 5. Orders Stream
  final List<MarketplaceOrder> orders = [
    MarketplaceOrder(
      id: 'ORD-8821',
      orderNumber: 1042,
      customerId: 'CUST-001',
      vendorId: 'VEND-001',
      subtotal: 1850.0,
      deliveryFee: 120.0,
      platformFee: 50.0,
      totalAmount: 2020.0,
      status: OrderStatus.outForDelivery,
      deliveryAddress: 'Main Bazaar Road, Near GPO, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    MarketplaceOrder(
      id: 'ORD-8820',
      orderNumber: 1041,
      customerId: 'CUST-002',
      vendorId: 'VEND-002',
      subtotal: 940.0,
      deliveryFee: 100.0,
      platformFee: 30.0,
      totalAmount: 1070.0,
      status: OrderStatus.preparing,
      deliveryAddress: 'Thana By-Pass Chowk, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
    ),
    MarketplaceOrder(
      id: 'ORD-8819',
      orderNumber: 1040,
      customerId: 'CUST-003',
      vendorId: 'VEND-001',
      subtotal: 3200.0,
      deliveryFee: 150.0,
      platformFee: 90.0,
      totalAmount: 3440.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'Civil Hospital Colony, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    MarketplaceOrder(
      id: 'ORD-8818',
      orderNumber: 1039,
      customerId: 'CUST-004',
      vendorId: 'VEND-003',
      subtotal: 650.0,
      deliveryFee: 80.0,
      platformFee: 20.0,
      totalAmount: 750.0,
      status: OrderStatus.placed,
      deliveryAddress: 'Ziarat Road, Mohalla Khanan, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // 6. Marketplace Categories
  final List<AdminCategory> categories = [
    AdminCategory(id: 'CAT-1', name: 'Restaurants & BBQ', iconName: 'restaurant', displayOrder: 1, isEnabled: true, productCount: 68),
    AdminCategory(id: 'CAT-2', name: 'Fresh Grocery', iconName: 'local_grocery_store', displayOrder: 2, isEnabled: true, productCount: 142),
    AdminCategory(id: 'CAT-3', name: 'Pharmacy & Care', iconName: 'local_pharmacy', displayOrder: 3, isEnabled: true, productCount: 85),
    AdminCategory(id: 'CAT-4', name: 'Bakery & Sweets', iconName: 'cake', displayOrder: 4, isEnabled: true, productCount: 34),
    AdminCategory(id: 'CAT-5', name: 'Fresh Fruits & Veg', iconName: 'eco', displayOrder: 5, isEnabled: true, productCount: 52),
    AdminCategory(id: 'CAT-6', name: 'General Stores', iconName: 'store', displayOrder: 6, isEnabled: false, productCount: 19),
  ];

  // 7. Dynamic Homepage Sections
  final List<AdminHomepageSection> homepageSections = [
    AdminHomepageSection(id: 'SEC-1', title: 'Top Promotional Hero Banners', sectionType: 'HeroCarousel', displayOrder: 1, isVisible: true),
    AdminHomepageSection(id: 'SEC-2', title: 'Explore Market Categories', sectionType: 'CategoryChipsGrid', displayOrder: 2, isVisible: true),
    AdminHomepageSection(id: 'SEC-3', title: 'Featured Batkhela Merchants', sectionType: 'FeaturedStoresSlider', displayOrder: 3, isVisible: true),
    AdminHomepageSection(id: 'SEC-4', title: 'Trending Lunch & BBQ Deals', sectionType: 'PopularProductsGrid', displayOrder: 4, isVisible: true),
    AdminHomepageSection(id: 'SEC-5', title: 'Special Weekend Discounts', sectionType: 'PromotionsBanner', displayOrder: 5, isVisible: false),
  ];

  // 8. Promotions & Campaigns
  final List<AdminPromotionCampaign> promotions = [
    AdminPromotionCampaign(
      id: 'PROM-101',
      title: 'Batkhela Grand BBQ Festival',
      storeName: 'Khyber Shinwari Tikka & Karahi',
      discountBannerText: 'Flat 15% OFF on all Shinwari Karahi & Tikka orders',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      isActive: true,
    ),
    AdminPromotionCampaign(
      id: 'PROM-102',
      title: 'Free Grocery Delivery Hour',
      storeName: 'Swat Valley Fresh Grocery',
      discountBannerText: 'Zero Delivery Fee on orders above Rs. 1,000',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      isActive: true,
    ),
  ];

  // 9. Multi-City Expansion & Settings
  final List<AdminCityRegion> regionalCities = [
    AdminCityRegion(id: 'CITY-1', cityName: 'Batkhela (Central & Bypass)', province: 'Khyber Pakhtunkhwa', isActive: true, vendorCount: 34),
    AdminCityRegion(id: 'CITY-2', cityName: 'Timergara', province: 'Khyber Pakhtunkhwa', isActive: false, vendorCount: 0),
    AdminCityRegion(id: 'CITY-3', cityName: 'Thana', province: 'Khyber Pakhtunkhwa', isActive: false, vendorCount: 0),
    AdminCityRegion(id: 'CITY-4', cityName: 'Mingora / Swat', province: 'Khyber Pakhtunkhwa', isActive: false, vendorCount: 0),
    AdminCityRegion(id: 'CITY-5', cityName: 'Dargai', province: 'Khyber Pakhtunkhwa', isActive: false, vendorCount: 0),
  ];

  final PlatformSettings settings = PlatformSettings();

  // ----------------------------------------------------
  // ACTION METHODS
  // ----------------------------------------------------

  void approveVendor(String id) {
    final index = vendors.indexWhere((v) => v.id == id);
    if (index != -1) {
      vendors[index].status = ApprovalStatus.approved;
      notifyListeners();
    }
  }

  void rejectVendor(String id) {
    final index = vendors.indexWhere((v) => v.id == id);
    if (index != -1) {
      vendors[index].status = ApprovalStatus.rejected;
      notifyListeners();
    }
  }

  void approveRider(String id) {
    final index = riders.indexWhere((r) => r.id == id);
    if (index != -1) {
      riders[index].status = ApprovalStatus.approved;
      notifyListeners();
    }
  }

  void rejectRider(String id) {
    final index = riders.indexWhere((r) => r.id == id);
    if (index != -1) {
      riders[index].status = ApprovalStatus.rejected;
      notifyListeners();
    }
  }

  void toggleCategory(String id, bool enabled) {
    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index].isEnabled = enabled;
      notifyListeners();
    }
  }

  void addCategory(String name, String iconName) {
    final newId = 'CAT-${categories.length + 1}';
    categories.add(AdminCategory(
      id: newId,
      name: name,
      iconName: iconName,
      displayOrder: categories.length + 1,
      isEnabled: true,
      productCount: 0,
    ));
    notifyListeners();
  }

  void toggleHomepageSection(String id, bool visible) {
    final index = homepageSections.indexWhere((s) => s.id == id);
    if (index != -1) {
      homepageSections[index].isVisible = visible;
      notifyListeners();
    }
  }

  void togglePromotion(String id, bool active) {
    final index = promotions.indexWhere((p) => p.id == id);
    if (index != -1) {
      promotions[index].isActive = active;
      notifyListeners();
    }
  }

  void toggleRegionalCity(String id, bool active) {
    final index = regionalCities.indexWhere((c) => c.id == id);
    if (index != -1) {
      regionalCities[index].isActive = active;
      notifyListeners();
    }
  }

  void updateSettings({
    String? marketplaceName,
    String? defaultCity,
    double? baseDeliveryFee,
    double? platformCommissionPercent,
    String? supportPhone,
  }) {
    if (marketplaceName != null) settings.marketplaceName = marketplaceName;
    if (defaultCity != null) settings.defaultCity = defaultCity;
    if (baseDeliveryFee != null) settings.baseDeliveryFee = baseDeliveryFee;
    if (platformCommissionPercent != null) settings.platformCommissionPercent = platformCommissionPercent;
    if (supportPhone != null) settings.supportPhone = supportPhone;
    notifyListeners();
  }
}
