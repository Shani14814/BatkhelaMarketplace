import 'package:flutter/material.dart';

/// Delivery Stage Progression for Rider
enum DeliveryStage {
  offered,
  accepted,
  arrivedAtPickup,
  pickedUp,
  onTheWay,
  delivered,
  declined;

  String get displayName {
    switch (this) {
      case DeliveryStage.offered:
        return 'Assignment Offered';
      case DeliveryStage.accepted:
        return 'Heading to Store';
      case DeliveryStage.arrivedAtPickup:
        return 'Arrived at Store';
      case DeliveryStage.pickedUp:
        return 'Order Picked Up';
      case DeliveryStage.onTheWay:
        return 'Out for Delivery';
      case DeliveryStage.delivered:
        return 'Delivered';
      case DeliveryStage.declined:
        return 'Declined';
    }
  }

  String get nextActionLabel {
    switch (this) {
      case DeliveryStage.offered:
        return 'Accept Assignment';
      case DeliveryStage.accepted:
        return 'Arrived at Store';
      case DeliveryStage.arrivedAtPickup:
        return 'Confirm Items & Pickup';
      case DeliveryStage.pickedUp:
        return 'Start Delivery to Customer';
      case DeliveryStage.onTheWay:
        return 'Confirm Delivery & Collect Cash';
      case DeliveryStage.delivered:
      case DeliveryStage.declined:
        return 'Completed';
    }
  }
}

/// Delivery Assignment Model for Rider
class RiderDeliveryAssignment {
  final String id;
  final String orderId;
  final int orderNumber;
  final String storeName;
  final String pickupAddress;
  final String customerArea;
  final String customerAddress;
  final String? customerNotes;
  final List<String> itemNames;
  final double cashToCollect;
  final double deliveryFeeEarnings;
  final double tipEarnings;
  final double distanceKm;
  final int estimatedMinutes;
  DeliveryStage stage;
  final DateTime createdAt;

  RiderDeliveryAssignment({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.storeName,
    required this.pickupAddress,
    required this.customerArea,
    required this.customerAddress,
    this.customerNotes,
    required this.itemNames,
    required this.cashToCollect,
    required this.deliveryFeeEarnings,
    this.tipEarnings = 0.0,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.stage = DeliveryStage.offered,
    required this.createdAt,
  });

  double get totalEarnings => deliveryFeeEarnings + tipEarnings;
}

/// Rider Profile Model
class RiderProfile {
  String name;
  String phone;
  String vehicleModel;
  String licenseNumber;
  String cnic;
  double rating;
  int completedDeliveriesCount;
  bool isVerified;

  RiderProfile({
    required this.name,
    required this.phone,
    required this.vehicleModel,
    required this.licenseNumber,
    required this.cnic,
    this.rating = 4.9,
    this.completedDeliveriesCount = 280,
    this.isVerified = true,
  });
}

/// Centralized In-Memory Rider State Controller
class RiderDemoController extends ChangeNotifier {
  static final RiderDemoController instance = RiderDemoController._();
  RiderDemoController._();

  bool isOnline = true;

  final RiderProfile profile = RiderProfile(
    name: 'Kamran Khan',
    phone: '+92 344 1122334',
    vehicleModel: 'Honda CG 125 (Khyber Red)',
    licenseNumber: 'BK-M-2024-88',
    cnic: '15402-1234567-1',
    rating: 4.9,
    completedDeliveriesCount: 284,
    isVerified: true,
  );

  void toggleOnlineStatus(bool online) {
    isOnline = online;
    notifyListeners();
  }

  // Delivery assignments list
  final List<RiderDeliveryAssignment> assignments = [
    // 1. Active In-Progress Delivery
    RiderDeliveryAssignment(
      id: 'DEL-1042',
      orderId: 'ORD-501',
      orderNumber: 1042,
      storeName: 'Khyber Shinwari Tikka & Karahi',
      pickupAddress: 'Main GT Road, Near Bypass Chowk, Batkhela',
      customerArea: 'Main Bazaar Road',
      customerAddress: 'Main Bazaar Road, Near GPO, Batkhela',
      customerNotes: 'Please call upon reaching near GPO, shop 2nd floor.',
      itemNames: [
        'Shinwari Mutton Karahi (Full KG)',
        '4x Kandahari Roghani Naan',
      ],
      cashToCollect: 2280.0,
      deliveryFeeEarnings: 150.0,
      tipEarnings: 50.0,
      distanceKm: 2.4,
      estimatedMinutes: 8,
      stage: DeliveryStage.onTheWay,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),

    // 2. New Assignment Offer 1
    RiderDeliveryAssignment(
      id: 'DEL-1043',
      orderId: 'ORD-502',
      orderNumber: 1043,
      storeName: 'Swat Valley Super Mart',
      pickupAddress: 'Bazaar Main Road, Batkhela',
      customerArea: 'Civil Hospital Colony',
      customerAddress: 'Civil Hospital Colony, House #14, Batkhela',
      customerNotes: 'Deliver groceries to main gate.',
      itemNames: [
        'Nestle MilkPak 1L (Pack of 6)',
        'Basmati Super Kernel Rice (5 KG)',
      ],
      cashToCollect: 1400.0,
      deliveryFeeEarnings: 120.0,
      tipEarnings: 0.0,
      distanceKm: 1.8,
      estimatedMinutes: 6,
      stage: DeliveryStage.offered,
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),

    // 3. New Assignment Offer 2
    RiderDeliveryAssignment(
      id: 'DEL-1046',
      orderId: 'ORD-507',
      orderNumber: 1046,
      storeName: 'Batkhela BBQ House & Biryani',
      pickupAddress: 'Main Bazaar Road, Near Clock Tower, Batkhela',
      customerArea: 'Zafar Park Road',
      customerAddress: 'Zafar Park Road, Opp. Park Gate, Batkhela',
      customerNotes: 'Please carry change for 1000 note.',
      itemNames: [
        'Chicken Malai Boti Plate (8 Pcs)',
        'Special Malakand Chicken Biryani (Double)',
      ],
      cashToCollect: 1110.0,
      deliveryFeeEarnings: 110.0,
      tipEarnings: 30.0,
      distanceKm: 2.1,
      estimatedMinutes: 7,
      stage: DeliveryStage.offered,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),

    // 4. Completed Trip 1
    RiderDeliveryAssignment(
      id: 'DEL-1038',
      orderId: 'ORD-504',
      orderNumber: 1038,
      storeName: 'Batkhela Central Pharmacy',
      pickupAddress: 'Hospital Road, Batkhela',
      customerArea: 'Zafar Park Road',
      customerAddress: 'Zafar Park Road, Batkhela',
      itemNames: [
        'Panadol Extra Tablets (Box of 20)',
        'First Aid Emergency Care Kit',
      ],
      cashToCollect: 910.0,
      deliveryFeeEarnings: 100.0,
      tipEarnings: 30.0,
      distanceKm: 3.1,
      estimatedMinutes: 10,
      stage: DeliveryStage.delivered,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    ),

    // 5. Completed Trip 2
    RiderDeliveryAssignment(
      id: 'DEL-1035',
      orderId: 'ORD-505',
      orderNumber: 1035,
      storeName: 'Malakand Sweets & Bakers',
      pickupAddress: 'Thana Road, Batkhela',
      customerArea: 'Degree College Road',
      customerAddress: 'Degree College Road, Batkhela',
      itemNames: [
        'Fresh Batkhela Gulab Jamun (1 KG Box)',
        'Traditional Khoya Peda & Barfi Mix (1 KG)',
      ],
      cashToCollect: 1600.0,
      deliveryFeeEarnings: 130.0,
      tipEarnings: 40.0,
      distanceKm: 2.7,
      estimatedMinutes: 9,
      stage: DeliveryStage.delivered,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    ),

    // 6. Completed Trip 3
    RiderDeliveryAssignment(
      id: 'DEL-1031',
      orderId: 'ORD-499',
      orderNumber: 1031,
      storeName: 'Fresh Sabzi & Fruits Mandi Batkhela',
      pickupAddress: 'Sabzi Mandi Road, Batkhela',
      customerArea: 'Civil Hospital Colony',
      customerAddress: 'Civil Hospital Colony, Batkhela',
      itemNames: [
        'Crisp Swat Red Apples (1 KG)',
        'Fresh Batkhela Farm Tomatoes (2 KG Basket)',
      ],
      cashToCollect: 420.0,
      deliveryFeeEarnings: 100.0,
      tipEarnings: 20.0,
      distanceKm: 1.6,
      estimatedMinutes: 5,
      stage: DeliveryStage.delivered,
      createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 10)),
    ),
  ];

  // Active in-progress delivery
  RiderDeliveryAssignment? get activeDelivery {
    final activeList = assignments.where((a) =>
        a.stage == DeliveryStage.accepted ||
        a.stage == DeliveryStage.arrivedAtPickup ||
        a.stage == DeliveryStage.pickedUp ||
        a.stage == DeliveryStage.onTheWay);
    return activeList.isNotEmpty ? activeList.first : null;
  }

  // Pending assignment offers
  List<RiderDeliveryAssignment> get offeredAssignments =>
      assignments.where((a) => a.stage == DeliveryStage.offered).toList();

  // Completed deliveries
  List<RiderDeliveryAssignment> get completedAssignments =>
      assignments.where((a) => a.stage == DeliveryStage.delivered).toList();

  // Actions & Transitions
  void acceptAssignment(String id) {
    final index = assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      assignments[index].stage = DeliveryStage.accepted;
      notifyListeners();
    }
  }

  void declineAssignment(String id) {
    final index = assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      assignments[index].stage = DeliveryStage.declined;
      notifyListeners();
    }
  }

  void progressDeliveryStage(String id) {
    final index = assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = assignments[index].stage;
      switch (current) {
        case DeliveryStage.offered:
          assignments[index].stage = DeliveryStage.accepted;
          break;
        case DeliveryStage.accepted:
          assignments[index].stage = DeliveryStage.arrivedAtPickup;
          break;
        case DeliveryStage.arrivedAtPickup:
          assignments[index].stage = DeliveryStage.pickedUp;
          break;
        case DeliveryStage.pickedUp:
          assignments[index].stage = DeliveryStage.onTheWay;
          break;
        case DeliveryStage.onTheWay:
          assignments[index].stage = DeliveryStage.delivered;
          break;
        case DeliveryStage.delivered:
        case DeliveryStage.declined:
          break;
      }
      notifyListeners();
    }
  }

  // Financial & Stats summaries
  double get todayEarnings => completedAssignments.fold(0.0, (sum, a) => sum + a.totalEarnings) +
      (activeDelivery != null && activeDelivery!.stage == DeliveryStage.delivered ? activeDelivery!.totalEarnings : 0.0);

  int get todayCompletedCount => completedAssignments.length;
}
