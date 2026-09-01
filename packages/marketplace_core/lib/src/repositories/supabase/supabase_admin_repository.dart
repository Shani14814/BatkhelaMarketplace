import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vendor.dart';
import '../../models/rider_profile.dart';
import '../../models/platform_setting.dart';
import '../admin_repository.dart';

class SupabaseAdminRepository implements AdminRepository {
  final SupabaseClient _client;

  SupabaseAdminRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> getPlatformKpis() async {
    final vendorsRes = await _client.from('vendors').select('id').eq('is_verified', true);
    final activeVendorsCount = (vendorsRes as List).length;

    final ridersRes = await _client.from('rider_profiles').select('id').eq('approval_status', 'approved');
    final activeRidersCount = (ridersRes as List).length;

    final ordersRes = await _client.from('orders').select('total_amount, platform_fee');
    double totalGmv = 0.0;
    double netCommission = 0.0;
    for (final o in (ordersRes as List)) {
      totalGmv += (o['total_amount'] as num?)?.toDouble() ?? 0.0;
      netCommission += (o['platform_fee'] as num?)?.toDouble() ?? 0.0;
    }

    return {
      'totalGmv': totalGmv,
      'todayOrders': ordersRes.length,
      'activeVendors': activeVendorsCount,
      'activeRiders': activeRidersCount,
      'netCommission': netCommission,
      'customerSatisfaction': 4.9,
    };
  }

  @override
  Future<List<Vendor>> getPendingVendors() async {
    final response = await _client
        .from('vendors')
        .select()
        .eq('is_verified', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<Vendor>> streamPendingVendors() {
    return _client
        .from('vendors')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => Vendor.fromJson(json))
            .where((v) => !v.isVerified)
            .toList());
  }

  @override
  Future<Vendor> updateVendorApproval(String vendorId, bool isVerified) async {
    final response = await _client
        .from('vendors')
        .update({
          'is_verified': isVerified,
          'is_open': isVerified,
        })
        .eq('id', vendorId)
        .select()
        .single();

    return Vendor.fromJson(response);
  }

  @override
  Future<List<RiderProfile>> getPendingRiderApplications() async {
    final response = await _client
        .from('rider_profiles')
        .select()
        .eq('approval_status', 'pending');

    return (response as List)
        .map((json) => RiderProfile.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<RiderProfile>> streamPendingRiderApplications() {
    return _client
        .from('rider_profiles')
        .stream(primaryKey: ['id'])
        .map((data) => data
            .map((json) => RiderProfile.fromJson(json))
            .where((r) => !r.isVerified)
            .toList());
  }

  @override
  Future<RiderProfile> updateRiderApproval(String riderId, bool isVerified) async {
    final response = await _client
        .from('rider_profiles')
        .update({
          'approval_status': isVerified ? 'approved' : 'rejected',
          'is_available': isVerified,
        })
        .eq('id', riderId)
        .select()
        .single();

    return RiderProfile.fromJson(response);
  }

  @override
  Future<List<ServiceCity>> getServiceCities() async {
    final response = await _client
        .from('service_cities')
        .select()
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => ServiceCity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ServiceCity> toggleCityActive(String cityId, bool isActive) async {
    final response = await _client
        .from('service_cities')
        .update({'is_active': isActive})
        .eq('id', cityId)
        .select()
        .single();

    return ServiceCity.fromJson(response);
  }

  @override
  Future<List<Promotion>> getPromotions() async {
    final response = await _client
        .from('promotions')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Promotion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<Promotion>> streamPromotions() {
    return _client
        .from('promotions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Promotion.fromJson(json)).toList());
  }

  @override
  Future<Promotion> togglePromotionActive(String promoId, bool isActive) async {
    final response = await _client
        .from('promotions')
        .update({'is_active': isActive})
        .eq('id', promoId)
        .select()
        .single();

    return Promotion.fromJson(response);
  }
}
