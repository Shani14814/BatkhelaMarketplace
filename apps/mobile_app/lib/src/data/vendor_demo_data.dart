import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

/// Rider Application Status
enum RiderApplicationStatus { pending, approved, rejected }

/// Demo Rider application model for Vendor rider management
class DemoRiderApplication {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String cnic;
  final double rating;
  final int completedDeliveries;
  RiderApplicationStatus status;

  DemoRiderApplication({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.cnic,
    this.rating = 4.8,
    this.completedDeliveries = 142,
    this.status = RiderApplicationStatus.pending,
  });
}

/// Vendor Store Profile Model
class VendorStoreProfile {
  String name;
  String category;
  String phone;
  String address;
  String operatingHours;
  bool isOpen;
  double rating;
  int reviewCount;

  VendorStoreProfile({
    required this.name,
    required this.category,
    required this.phone,
    required this.address,
    required this.operatingHours,
    this.isOpen = true,
    this.rating = 4.9,
    this.reviewCount = 240,
  });
}

/// Centralized In-Memory Vendor Demo State Controller
class VendorDemoController extends ChangeNotifier {
  static final VendorDemoController instance = VendorDemoController._();
  VendorDemoController._();

  // Store Profile
  final VendorStoreProfile store = VendorStoreProfile(
    name: 'Khyber Shinwari Tikka & Karahi',
    category: 'Restaurants & BBQ',
    phone: '+92 345 9876543',
    address: 'Main GT Road, Near Bypass Chowk, Batkhela',
    operatingHours: '11:00 AM – 11:30 PM (Daily)',
    isOpen: true,
    rating: 4.9,
    reviewCount: 240,
  );

  void toggleStoreOpenStatus(bool isOpen) {
    store.isOpen = isOpen;
    notifyListeners();
  }

  void updateStoreProfile({
    required String name,
    required String category,
    required String phone,
    required String address,
    required String operatingHours,
  }) {
    store.name = name;
    store.category = category;
    store.phone = phone;
    store.address = address;
    store.operatingHours = operatingHours;
    notifyListeners();
  }

  // Live Orders
  final List<MarketplaceOrder> orders = [
    MarketplaceOrder(
      id: 'ORD-501',
      orderNumber: 1042,
      customerId: 'CUST-01',
      vendorId: 'store-1',
      subtotal: 2150.0,
      deliveryFee: 100.0,
      platformFee: 30.0,
      totalAmount: 2280.0,
      status: OrderStatus.placed,
      deliveryAddress: 'Main Bazaar Road, Near GPO, Batkhela',
      customerNotes: 'Please prepare medium spicy and include extra raita.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      items: const [
        OrderItem(
          id: 'it-1',
          orderId: 'ORD-501',
          productName: 'Shinwari Mutton Karahi (Full KG)',
          unitPrice: 2150.0,
          quantity: 1,
          totalPrice: 2150.0,
        ),
      ],
    ),
    MarketplaceOrder(
      id: 'ORD-502',
      orderNumber: 1043,
      customerId: 'CUST-02',
      vendorId: 'store-1',
      subtotal: 1300.0,
      deliveryFee: 80.0,
      platformFee: 20.0,
      totalAmount: 1400.0,
      status: OrderStatus.accepted,
      deliveryAddress: 'Civil Hospital Colony, House #14, Batkhela',
      customerNotes: 'Please send hot naan fresh from tandoor.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      items: const [
        OrderItem(
          id: 'it-2',
          orderId: 'ORD-502',
          productName: 'Dumba Namkeen Tikka Skewer',
          unitPrice: 580.0,
          quantity: 2,
          totalPrice: 1160.0,
        ),
        OrderItem(
          id: 'it-3',
          orderId: 'ORD-502',
          productName: 'Kandahari Roghani Naan',
          unitPrice: 40.0,
          quantity: 3,
          totalPrice: 120.0,
        ),
      ],
    ),
    MarketplaceOrder(
      id: 'ORD-503',
      orderNumber: 1040,
      customerId: 'CUST-03',
      vendorId: 'store-1',
      subtotal: 720.0,
      deliveryFee: 50.0,
      platformFee: 20.0,
      totalAmount: 790.0,
      status: OrderStatus.preparing,
      deliveryAddress: 'Degree College Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
      items: const [
        OrderItem(
          id: 'it-4',
          orderId: 'ORD-503',
          productName: 'Peshawari Chapli Kabab (Per Piece)',
          unitPrice: 180.0,
          quantity: 4,
          totalPrice: 720.0,
        ),
      ],
    ),
    MarketplaceOrder(
      id: 'ORD-504',
      orderNumber: 1038,
      customerId: 'CUST-04',
      vendorId: 'store-1',
      subtotal: 4300.0,
      deliveryFee: 0.0,
      platformFee: 50.0,
      totalAmount: 4350.0,
      status: OrderStatus.readyForPickup,
      deliveryAddress: 'Zafar Park Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      items: const [
        OrderItem(
          id: 'it-5',
          orderId: 'ORD-504',
          productName: 'Shinwari Mutton Karahi (Full KG)',
          unitPrice: 2150.0,
          quantity: 2,
          totalPrice: 4300.0,
        ),
      ],
    ),
    MarketplaceOrder(
      id: 'ORD-505',
      orderNumber: 1035,
      customerId: 'CUST-05',
      vendorId: 'store-1',
      subtotal: 1800.0,
      deliveryFee: 100.0,
      platformFee: 30.0,
      totalAmount: 1930.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'Thana Road, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      items: const [
        OrderItem(
          id: 'it-6',
          orderId: 'ORD-505',
          productName: 'Dumba Namkeen Tikka Skewer',
          unitPrice: 580.0,
          quantity: 3,
          totalPrice: 1740.0,
        ),
      ],
    ),
  ];

  // Order Lifecycle Transitions
  void acceptOrder(String orderId) {
    _updateOrderStatus(orderId, OrderStatus.accepted);
  }

  void rejectOrder(String orderId) {
    _updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  void startPreparing(String orderId) {
    _updateOrderStatus(orderId, OrderStatus.preparing);
  }

  void markReadyForPickup(String orderId) {
    _updateOrderStatus(orderId, OrderStatus.readyForPickup);
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = orders[index];
      orders[index] = MarketplaceOrder(
        id: old.id,
        orderNumber: old.orderNumber,
        customerId: old.customerId,
        vendorId: old.vendorId,
        subtotal: old.subtotal,
        deliveryFee: old.deliveryFee,
        platformFee: old.platformFee,
        totalAmount: old.totalAmount,
        status: newStatus,
        deliveryAddress: old.deliveryAddress,
        customerNotes: old.customerNotes,
        items: old.items,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  // Product Catalog
  final List<Product> products = [
    Product(
      id: 'prod-1',
      vendorId: 'store-1',
      name: 'Shinwari Mutton Karahi (Full KG)',
      description: 'Prepared in pure lamb fat with fresh tomatoes, green chillies & ginger',
      price: 2400.0,
      discountPrice: 2150.0,
      category: 'Karahi Special',
      isAvailable: true,
      stockQuantity: 25,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-2',
      vendorId: 'store-1',
      name: 'Peshawari Chapli Kabab (Per Piece)',
      description: 'Spiced beef patty garnished with fresh tomato slices and coriander',
      price: 180.0,
      category: 'Kababs & BBQ',
      isAvailable: true,
      stockQuantity: 60,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-3',
      vendorId: 'store-1',
      name: 'Dumba Namkeen Tikka Skewer',
      description: 'Charcoal grilled salted mutton chunks on skewers',
      price: 650.0,
      discountPrice: 580.0,
      category: 'Kababs & BBQ',
      isAvailable: true,
      stockQuantity: 40,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-4',
      vendorId: 'store-1',
      name: 'Kandahari Roghani Naan',
      description: 'Tandoori sesame seed flatbread with butter coating',
      price: 40.0,
      category: 'Tandoor',
      isAvailable: true,
      stockQuantity: 120,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-5',
      vendorId: 'store-1',
      name: 'Special Malakand Raita & Salad Bowl',
      description: 'Chilled mint zeera yogurt with fresh cucumber and onion salad',
      price: 100.0,
      category: 'Sides',
      isAvailable: false,
      stockQuantity: 0,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  void toggleProductAvailability(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final old = products[index];
      products[index] = Product(
        id: old.id,
        vendorId: old.vendorId,
        categoryId: old.categoryId,
        category: old.category,
        name: old.name,
        description: old.description,
        price: old.price,
        discountPrice: old.discountPrice,
        stockQuantity: old.stockQuantity,
        isAvailable: !old.isAvailable,
        imageUrl: old.imageUrl,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  void addProduct({
    required String name,
    required String category,
    required double price,
    double? discountPrice,
    required String description,
  }) {
    final newProduct = Product(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      vendorId: 'store-1',
      name: name,
      category: category,
      price: price,
      discountPrice: discountPrice,
      description: description,
      isAvailable: true,
      stockQuantity: 50,
      createdAt: DateTime.now(),
    );
    products.insert(0, newProduct);
    notifyListeners();
  }

  void editProduct({
    required String id,
    required String name,
    required String category,
    required double price,
    double? discountPrice,
    required String description,
  }) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = products[index];
      products[index] = Product(
        id: old.id,
        vendorId: old.vendorId,
        categoryId: old.categoryId,
        category: category,
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        stockQuantity: old.stockQuantity,
        isAvailable: old.isAvailable,
        imageUrl: old.imageUrl,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  // Rider Applications
  final List<DemoRiderApplication> riderApplications = [
    DemoRiderApplication(
      id: 'rider-01',
      name: 'Kamran Khan',
      phone: '+92 344 1122334',
      vehicleType: 'Honda 125cc Motorbike',
      cnic: '15402-1234567-1',
      rating: 4.9,
      completedDeliveries: 280,
      status: RiderApplicationStatus.approved,
    ),
    DemoRiderApplication(
      id: 'rider-02',
      name: 'Sohail Ahmad',
      phone: '+92 301 5566778',
      vehicleType: 'United 70cc Motorbike',
      cnic: '15402-9876543-3',
      rating: 4.8,
      completedDeliveries: 95,
      status: RiderApplicationStatus.approved,
    ),
    DemoRiderApplication(
      id: 'rider-03',
      name: 'Naveed Malakand',
      phone: '+92 333 7788990',
      vehicleType: 'Super Power 70cc',
      cnic: '15402-5544332-9',
      rating: 4.7,
      completedDeliveries: 34,
      status: RiderApplicationStatus.pending,
    ),
  ];

  void approveRider(String riderId) {
    final index = riderApplications.indexWhere((r) => r.id == riderId);
    if (index != -1) {
      riderApplications[index].status = RiderApplicationStatus.approved;
      notifyListeners();
    }
  }

  void rejectRider(String riderId) {
    final index = riderApplications.indexWhere((r) => r.id == riderId);
    if (index != -1) {
      riderApplications[index].status = RiderApplicationStatus.rejected;
      notifyListeners();
    }
  }

  // Operational Metrics
  double get todayRevenue => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.subtotal);

  int get pendingOrdersCount =>
      orders.where((o) => o.status == OrderStatus.placed).length;

  int get activeOrdersCount => orders
      .where((o) =>
          o.status == OrderStatus.placed ||
          o.status == OrderStatus.accepted ||
          o.status == OrderStatus.preparing ||
          o.status == OrderStatus.readyForPickup)
      .length;
}
