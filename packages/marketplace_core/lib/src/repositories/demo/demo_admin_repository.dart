import '../../models/vendor.dart';
import '../../models/rider_profile.dart';
import '../../models/platform_setting.dart';
import '../admin_repository.dart';

class DemoAdminRepository implements AdminRepository {
  final List<Vendor> _pendingVendors = [
    Vendor(
      id: 'vendor-pending-1',
      storeName: 'Swat Organic Honey & Dry Fruits',
      slug: 'swat-organic-honey',
      description: 'Pure Sidr and Wildflower Honey with walnuts, almonds, and dried figs from Swat.',
      address: 'Near Timber Market, Batkhela',
      phone: '+92 345 7788990',
      commissionRate: 10.0,
      isOpen: false,
      isVerified: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<RiderProfile> _pendingRiders = [
    const RiderProfile(
      id: 'rider-app-1',
      userId: 'user-app-1',
      vehicleType: 'United 70cc',
      vehicleNumber: 'MNR-9012',
      cnicNumber: '15402-9988776-5',
      licenseNumber: 'BK-LR-11029',
      isVerified: false,
      rating: 5.0,
      totalDeliveries: 0,
      fullName: 'Kamran Ullah',
      phone: '+92 345 5544332',
    ),
  ];

  final List<ServiceCity> _serviceCities = [
    const ServiceCity(
      id: 'city-1',
      name: 'Batkhela',
      province: 'Khyber Pakhtunkhwa',
      isActive: true,
      deliveryRadiusKm: 15.0,
    ),
    const ServiceCity(
      id: 'city-2',
      name: 'Thana',
      province: 'Khyber Pakhtunkhwa',
      isActive: true,
      deliveryRadiusKm: 12.0,
    ),
    const ServiceCity(
      id: 'city-3',
      name: 'Dargai',
      province: 'Khyber Pakhtunkhwa',
      isActive: false,
      deliveryRadiusKm: 10.0,
    ),
    const ServiceCity(
      id: 'city-4',
      name: 'Chakdara',
      province: 'Khyber Pakhtunkhwa',
      isActive: false,
      deliveryRadiusKm: 10.0,
    ),
  ];

  final List<Promotion> _promotions = [
    Promotion(
      id: 'promo-1',
      code: 'BATKHELAFREE',
      title: 'Free Delivery on First 3 Orders',
      discountPercent: 100.0,
      maxDiscountAmount: 150.0,
      minOrderAmount: 500.0,
      isActive: true,
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
    Promotion(
      id: 'promo-2',
      code: 'SHINWARI20',
      title: '20% OFF on Khyber Shinwari Karahi',
      discountPercent: 20.0,
      maxDiscountAmount: 500.0,
      minOrderAmount: 1500.0,
      isActive: true,
      validUntil: DateTime.now().add(const Duration(days: 15)),
    ),
  ];

  @override
  Future<Map<String, dynamic>> getPlatformKpis() async {
    return {
      'totalGmv': 428500.0,
      'todayOrders': 148,
      'activeVendors': 32,
      'activeRiders': 18,
      'netCommission': 38560.0,
      'customerSatisfaction': 4.88,
    };
  }

  @override
  Future<List<Vendor>> getPendingVendors() async {
    return List.unmodifiable(_pendingVendors);
  }

  @override
  Future<Vendor> updateVendorApproval(String vendorId, bool isVerified) async {
    final index = _pendingVendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      final existing = _pendingVendors[index];
      final updated = Vendor(
        id: existing.id,
        storeName: existing.storeName,
        slug: existing.slug,
        description: existing.description,
        logoUrl: existing.logoUrl,
        bannerUrl: existing.bannerUrl,
        address: existing.address,
        latitude: existing.latitude,
        longitude: existing.longitude,
        phone: existing.phone,
        commissionRate: existing.commissionRate,
        isOpen: isVerified,
        isVerified: isVerified,
        createdAt: existing.createdAt,
      );
      _pendingVendors.removeAt(index);
      return updated;
    }
    throw Exception('Vendor application not found');
  }

  @override
  Future<List<RiderProfile>> getPendingRiderApplications() async {
    return List.unmodifiable(_pendingRiders);
  }

  @override
  Future<RiderProfile> updateRiderApproval(String riderId, bool isVerified) async {
    final index = _pendingRiders.indexWhere((r) => r.id == riderId);
    if (index != -1) {
      final existing = _pendingRiders[index];
      final updated = existing.copyWith(isVerified: isVerified);
      _pendingRiders.removeAt(index);
      return updated;
    }
    throw Exception('Rider application not found');
  }

  @override
  Future<List<ServiceCity>> getServiceCities() async {
    return List.unmodifiable(_serviceCities);
  }

  @override
  Future<ServiceCity> toggleCityActive(String cityId, bool isActive) async {
    final index = _serviceCities.indexWhere((c) => c.id == cityId);
    if (index != -1) {
      final updated = _serviceCities[index].copyWith(isActive: isActive);
      _serviceCities[index] = updated;
      return updated;
    }
    throw Exception('City not found');
  }

  @override
  Future<List<Promotion>> getPromotions() async {
    return List.unmodifiable(_promotions);
  }

  @override
  Future<Promotion> togglePromotionActive(String promoId, bool isActive) async {
    final index = _promotions.indexWhere((p) => p.id == promoId);
    if (index != -1) {
      final updated = _promotions[index].copyWith(isActive: isActive);
      _promotions[index] = updated;
      return updated;
    }
    throw Exception('Promotion not found');
  }
}
