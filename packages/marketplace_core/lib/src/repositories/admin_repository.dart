import 'dart:async';
import '../models/vendor.dart';
import '../models/rider_profile.dart';
import '../models/platform_setting.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> getPlatformKpis();
  Future<List<Vendor>> getPendingVendors();
  Future<Vendor> updateVendorApproval(String vendorId, bool isVerified);
  Future<List<RiderProfile>> getPendingRiderApplications();
  Future<RiderProfile> updateRiderApproval(String riderId, bool isVerified);
  Future<List<ServiceCity>> getServiceCities();
  Future<ServiceCity> toggleCityActive(String cityId, bool isActive);
  Future<List<Promotion>> getPromotions();
  Future<Promotion> togglePromotionActive(String promoId, bool isActive);

  // Realtime Streams (Phase 7E)
  Stream<List<Vendor>> streamPendingVendors();
  Stream<List<RiderProfile>> streamPendingRiderApplications();
  Stream<List<Promotion>> streamPromotions();
}
