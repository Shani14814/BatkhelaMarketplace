import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'customer_demo_data.dart';
import 'rider_demo_data.dart';

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
  String? ownerName;
  String? cnic;
  String? logoUrl;
  String? bannerUrl;
  bool isOpen;
  bool isVerified;
  String applicationStatus; // 'submitted', 'approved', 'rejected'
  double rating;
  int reviewCount;

  VendorStoreProfile({
    required this.name,
    required this.category,
    required this.phone,
    required this.address,
    required this.operatingHours,
    this.ownerName = 'Khyber Shinwari Master Chef',
    this.cnic = '15402-9876543-1',
    this.logoUrl = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
    this.bannerUrl = 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&q=80',
    this.isOpen = true,
    this.isVerified = true,
    this.applicationStatus = 'approved',
    this.rating = 4.9,
    this.reviewCount = 240,
  });
}

/// Centralized In-Memory Vendor Demo State Controller
class VendorDemoController extends ChangeNotifier {
  static final VendorDemoController instance = VendorDemoController._();
  VendorDemoController._();

  String activeStoreId = 'store-1';

  // Store Profile
  final VendorStoreProfile store = VendorStoreProfile(
    name: 'Khyber Shinwari Tikka & Karahi',
    category: 'Restaurants & BBQ',
    phone: '+92 345 9876543',
    address: 'Main GT Road, Near Bypass Chowk, Batkhela',
    operatingHours: '11:00 AM – 11:30 PM (Daily)',
    ownerName: 'Khyber Shinwari Master Chef',
    cnic: '15402-9876543-1',
    logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&q=80',
    isOpen: true,
    isVerified: true,
    applicationStatus: 'approved',
    rating: 4.9,
    reviewCount: 240,
  );

  bool get isCurrentVendorVerified => store.isVerified;

  /// Switch active demo vendor store to any of the 16 Batkhela stores
  void switchActiveVendorStore(String storeId) {
    final targetIndex = CustomerDemoData.stores.indexWhere((s) => s.id == storeId);
    if (targetIndex == -1) return;
    final target = CustomerDemoData.stores[targetIndex];

    activeStoreId = target.id;
    store.name = target.name;
    store.category = target.categoryName;
    store.phone = target.phone;
    store.address = target.address;
    store.operatingHours = target.operatingHours;
    store.ownerName = target.ownerName;
    store.logoUrl = target.logoUrl ?? target.imageUrl;
    store.bannerUrl = target.imageUrl;
    store.isOpen = target.isOpen;
    store.isVerified = true;
    store.applicationStatus = 'approved';
    store.rating = target.rating;
    store.reviewCount = target.reviewCount;

    products
      ..clear()
      ..addAll(target.products);

    notifyListeners();
  }

  void registerVendorStore({
    required String name,
    required String category,
    required String ownerName,
    required String phone,
    required String address,
    required String cnic,
    String? logoUrl,
    String? bannerUrl,
    String operatingHours = '10:00 AM – 10:00 PM',
  }) {
    store.name = name;
    store.category = category;
    store.ownerName = ownerName;
    store.phone = phone;
    store.address = address;
    store.cnic = cnic;
    if (logoUrl != null) store.logoUrl = logoUrl;
    if (bannerUrl != null) store.bannerUrl = bannerUrl;
    store.operatingHours = operatingHours;
    store.isVerified = false;
    store.applicationStatus = 'submitted';
    notifyListeners();
  }

  void approveVendorStore() {
    store.isVerified = true;
    store.applicationStatus = 'approved';
    notifyListeners();
  }

  void rejectVendorStore() {
    store.isVerified = false;
    store.applicationStatus = 'rejected';
    notifyListeners();
  }

  void resetToUnverifiedForTesting() {
    store.isVerified = false;
    store.applicationStatus = 'submitted';
    notifyListeners();
  }

  void toggleStoreOpenStatus(bool isOpen) {
    store.isOpen = isOpen;
    _syncWithCustomerCatalog();
    notifyListeners();
  }

  void updateStoreProfile({
    required String name,
    required String category,
    required String phone,
    required String address,
    required String operatingHours,
    String? logoUrl,
    String? bannerUrl,
  }) {
    store.name = name;
    store.category = category;
    store.phone = phone;
    store.address = address;
    store.operatingHours = operatingHours;
    if (logoUrl != null) store.logoUrl = logoUrl;
    if (bannerUrl != null) store.bannerUrl = bannerUrl;
    _syncWithCustomerCatalog();
    notifyListeners();
  }

  // Live Orders
  final List<MarketplaceOrder> orders = [
    // 1. Placed / Urgent Pending
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

    // 2. Placed / Pending
    MarketplaceOrder(
      id: 'ORD-506',
      orderNumber: 1045,
      customerId: 'CUST-06',
      vendorId: 'store-1',
      subtotal: 1100.0,
      deliveryFee: 60.0,
      platformFee: 20.0,
      totalAmount: 1180.0,
      status: OrderStatus.placed,
      deliveryAddress: 'Thana Road, Near Bridge, Batkhela',
      customerNotes: 'Please deliver hot with fresh lemon and ginger garnish.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      items: const [
        OrderItem(
          id: 'it-10',
          orderId: 'ORD-506',
          productName: 'Special Chicken White Karahi (Half KG)',
          unitPrice: 990.0,
          quantity: 1,
          totalPrice: 990.0,
        ),
        OrderItem(
          id: 'it-11',
          orderId: 'ORD-506',
          productName: 'Kandahari Roghani Naan',
          unitPrice: 40.0,
          quantity: 2,
          totalPrice: 80.0,
        ),
      ],
    ),

    // 3. Accepted
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

    // 4. In Kitchen / Preparing
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

    // 5. Ready for Pickup
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

    // 6. Delivered
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

  /// Vendor assigns the ready order to HIMSELF ("Khud Le Jayein / Vendor Self-Delivery")
  /// and starts Out for Delivery with live GPS broadcast to Customer!
  Future<void> assignOrderToVendorSelf(String orderId) async {
    double lat = RiderDemoController.instance.liveRiderLat;
    double lng = RiderDemoController.instance.liveRiderLng;
    final gps = await HostingerApiClient.instance.getCurrentDeviceGps();
    if (gps != null) {
      lat = gps.latitude;
      lng = gps.longitude;
      RiderDemoController.instance.liveRiderLat = lat;
      RiderDemoController.instance.liveRiderLng = lng;
    }

    final selfDisplayName = '${store.name} (Vendor Self-Delivery)';
    _updateOrderStatus(
      orderId,
      OrderStatus.outForDelivery,
      riderLat: lat,
      riderLng: lng,
      assignedRiderId: activeStoreId,
      assignedRiderName: selfDisplayName,
      deliveryAssignmentType: 'vendor_self',
    );
    unawaited(
      HostingerApiClient.instance.updateRiderLocation(
        orderId: orderId,
        riderLat: lat,
        riderLng: lng,
      ),
    );
  }

  /// Vendor assigns the ready order to a specific Rider from the Batkhela Rider Network
  void assignOrderToRider(
    String orderId, {
    required String riderId,
    required String riderName,
  }) {
    _updateOrderStatus(
      orderId,
      OrderStatus.readyForPickup,
      assignedRiderId: riderId,
      assignedRiderName: '$riderName (Assigned Rider)',
      deliveryAssignmentType: 'rider',
    );

    final ordIndex = orders.indexWhere((o) => o.id == orderId);
    if (ordIndex != -1) {
      final ord = orders[ordIndex];
      final rCtrl = RiderDemoController.instance;
      final existingIdx = rCtrl.assignments.indexWhere((a) => a.orderId == orderId);
      if (existingIdx == -1) {
        rCtrl.assignments.insert(
          0,
          RiderDeliveryAssignment(
            id: 'DEL-${ord.orderNumber ?? ord.id}',
            orderId: ord.id,
            orderNumber: ord.orderNumber ?? 1000,
            storeName: store.name,
            pickupAddress: store.address,
            customerArea: 'Batkhela Delivery Zone',
            customerAddress: ord.deliveryAddress,
            customerLat: ord.deliveryLat,
            customerLng: ord.deliveryLng,
            customerNotes: ord.customerNotes,
            itemNames: ord.items.isNotEmpty
                ? ord.items.map((i) => '${i.quantity}x ${i.productName}').toList()
                : ['Order #${ord.orderNumber ?? ord.id}'],
            cashToCollect: ord.totalAmount,
            deliveryFeeEarnings: ord.deliveryFee > 0 ? ord.deliveryFee : 100.0,
            distanceKm: 2.1,
            estimatedMinutes: 8,
            stage: DeliveryStage.accepted,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        rCtrl.assignments[existingIdx].stage = DeliveryStage.accepted;
      }
      rCtrl.notifyListeners();
    }
  }

  /// Broadcast Vendor's live GPS while Vendor is personally delivering the order
  Future<void> broadcastVendorSelfDeliveryGps(String orderId) async {
    final gps = await HostingerApiClient.instance.getCurrentDeviceGps();
    final lat = gps?.latitude ?? RiderDemoController.instance.liveRiderLat;
    final lng = gps?.longitude ?? RiderDemoController.instance.liveRiderLng;
    RiderDemoController.instance.liveRiderLat = lat;
    RiderDemoController.instance.liveRiderLng = lng;

    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx] = orders[idx].copyWith(riderLat: lat, riderLng: lng);
    }
    final cIdx = CustomerDemoData.demoOrders.indexWhere((o) => o.id == orderId);
    if (cIdx != -1) {
      CustomerDemoData.demoOrders[cIdx] =
          CustomerDemoData.demoOrders[cIdx].copyWith(riderLat: lat, riderLng: lng);
    }
    await HostingerApiClient.instance.updateRiderLocation(
      orderId: orderId,
      riderLat: lat,
      riderLng: lng,
    );
    notifyListeners();
  }

  /// Vendor completes delivery and marks order Delivered
  void markOrderDeliveredByVendor(String orderId) {
    _updateOrderStatus(orderId, OrderStatus.delivered);
  }

  void _updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    double? riderLat,
    double? riderLng,
    String? assignedRiderId,
    String? assignedRiderName,
    String? deliveryAssignmentType,
  }) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = orders[index];
      final updated = old.copyWith(
        status: newStatus,
        riderLat: riderLat,
        riderLng: riderLng,
        assignedRiderId: assignedRiderId,
        assignedRiderName: assignedRiderName,
        deliveryAssignmentType: deliveryAssignmentType,
      );
      orders[index] = updated;

      final cIdx = CustomerDemoData.demoOrders.indexWhere((o) => o.id == orderId);
      if (cIdx != -1) {
        CustomerDemoData.demoOrders[cIdx] = updated;
      }

      HostingerApiClient.instance.updateOrderStatus(
        orderId,
        newStatus,
        riderLat: riderLat,
        riderLng: riderLng,
        assignedRiderId: assignedRiderId ?? updated.assignedRiderId,
        assignedRiderName: assignedRiderName ?? updated.assignedRiderName,
        deliveryAssignmentType: deliveryAssignmentType ?? updated.deliveryAssignmentType,
      );
      notifyListeners();
    }
  }

  // Complete Rich Product Catalog for Vendor
  final List<Product> products = [
    Product(
      id: 'prod-1',
      vendorId: 'store-1',
      name: 'Shinwari Mutton Karahi (Full KG)',
      description: 'Prepared in pure lamb fat with fresh tomatoes, green chillies & ginger',
      price: 2400.0,
      discountPrice: 2150.0,
      category: 'Karahi Special',
      imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&auto=format&fit=crop&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=400&auto=format&fit=crop&q=80',
      isAvailable: true,
      stockQuantity: 120,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-5',
      vendorId: 'store-1',
      name: 'Special Chicken White Karahi (Half KG)',
      description: 'Mild black pepper yogurt chicken karahi prepared with fresh cream',
      price: 1100.0,
      discountPrice: 990.0,
      category: 'Karahi Special',
      imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&auto=format&fit=crop&q=80',
      isAvailable: true,
      stockQuantity: 30,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-6',
      vendorId: 'store-1',
      name: 'Chicken Malai Boti Skewer (6 Pcs)',
      description: 'Boneless tender chicken breast cubes marinated in cream and green herbs',
      price: 520.0,
      discountPrice: 480.0,
      category: 'Kababs & BBQ',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop&q=80',
      isAvailable: true,
      stockQuantity: 45,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-7',
      vendorId: 'store-1',
      name: 'Garlic Butter Naan',
      description: 'Fresh tandoori naan coated in minced garlic, parsley and desi butter',
      price: 60.0,
      category: 'Tandoor',
      imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=400&auto=format&fit=crop&q=80',
      isAvailable: true,
      stockQuantity: 80,
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'prod-8',
      vendorId: 'store-1',
      name: 'Special Malakand Raita & Salad Bowl',
      description: 'Chilled mint zeera yogurt with fresh cucumber and onion salad',
      price: 100.0,
      category: 'Sides & Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&auto=format&fit=crop&q=80',
      isAvailable: true,
      stockQuantity: 50,
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
      HostingerApiClient.instance.saveProduct(products[index]);
      _syncWithCustomerCatalog();
      notifyListeners();
    }
  }

  void addProduct({
    required String name,
    required String category,
    required double price,
    double? discountPrice,
    required String description,
    String? imageUrl,
    int stockQuantity = 50,
  }) {
    final newProduct = Product(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      vendorId: activeStoreId,
      name: name,
      category: category,
      price: price,
      discountPrice: discountPrice,
      description: description,
      imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&auto=format&fit=crop&q=80',
      isAvailable: true,
      stockQuantity: stockQuantity,
      createdAt: DateTime.now(),
    );
    products.insert(0, newProduct);
    HostingerApiClient.instance.saveProduct(newProduct);
    _syncWithCustomerCatalog();
    notifyListeners();
  }

  void editProduct({
    required String id,
    required String name,
    required String category,
    required double price,
    double? discountPrice,
    required String description,
    String? imageUrl,
    int? stockQuantity,
    bool? isAvailable,
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
        stockQuantity: stockQuantity ?? old.stockQuantity,
        isAvailable: isAvailable ?? old.isAvailable,
        imageUrl: imageUrl ?? old.imageUrl,
        createdAt: old.createdAt,
      );
      HostingerApiClient.instance.saveProduct(products[index]);
      _syncWithCustomerCatalog();
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    HostingerApiClient.instance.deleteProduct(id);
    _syncWithCustomerCatalog();
    notifyListeners();
  }

  void _syncWithCustomerCatalog() {
    // Synchronize active store in Customer Demo Data with current Vendor state
    final idx = CustomerDemoData.stores.indexWhere((s) => s.id == activeStoreId);
    if (idx != -1) {
      final oldStore = CustomerDemoData.stores[idx];
      CustomerDemoData.stores[idx] = DemoStore(
        id: oldStore.id,
        name: store.name,
        categoryId: oldStore.categoryId,
        categoryName: store.category,
        description: oldStore.description,
        address: store.address,
        rating: store.rating,
        reviewCount: store.reviewCount,
        deliveryTime: oldStore.deliveryTime,
        deliveryFee: oldStore.deliveryFee,
        badges: oldStore.badges,
        isOpen: store.isOpen,
        imageUrl: store.bannerUrl ?? oldStore.imageUrl,
        logoUrl: store.logoUrl ?? oldStore.logoUrl,
        ownerName: store.ownerName ?? oldStore.ownerName,
        phone: store.phone,
        operatingHours: store.operatingHours,
        products: List<Product>.from(products),
      );
      HostingerApiClient.instance.saveStore(
        CustomerDemoData.stores[idx].toJson(sortOrder: idx),
      );
    }
  }

  // Rider Applications Network
  final List<DemoRiderApplication> riderApplications = [
    DemoRiderApplication(
      id: 'rider-01',
      name: 'Kamran Khan',
      phone: '+92 344 1122334',
      vehicleType: 'Honda CG 125cc (Red)',
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
    DemoRiderApplication(
      id: 'rider-04',
      name: 'Bilal Khan Batkhela',
      phone: '+92 312 4433221',
      vehicleType: 'Honda CD 70cc',
      cnic: '15402-8877665-5',
      rating: 4.9,
      completedDeliveries: 62,
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
          o.status == OrderStatus.readyForPickup ||
          o.status == OrderStatus.outForDelivery)
      .length;
}
