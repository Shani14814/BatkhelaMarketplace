import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/rider_profile.dart';
import '../../models/delivery.dart';
import '../rider_repository.dart';

class SupabaseRiderRepository implements RiderRepository {
  final SupabaseClient _client;

  SupabaseRiderRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<RiderProfile?> getRiderProfile(String riderId) async {
    final response = await _client
        .from('rider_profiles')
        .select()
        .eq('id', riderId)
        .maybeSingle();

    if (response == null) return null;
    return RiderProfile.fromJson(response);
  }

  @override
  Stream<RiderProfile?> streamRiderProfile(String riderId) {
    return _client
        .from('rider_profiles')
        .stream(primaryKey: ['id'])
        .eq('id', riderId)
        .map((data) => data.isNotEmpty ? RiderProfile.fromJson(data.first) : null);
  }

  @override
  Future<void> updateOnlineStatus(String riderId, bool isOnline) async {
    await _client.from('rider_locations').upsert({
      'rider_id': riderId,
      'is_online': isOnline,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateTelemetryLocation(
    String riderId, {
    required double latitude,
    required double longitude,
    double heading = 0.0,
  }) async {
    await _client.from('rider_locations').upsert({
      'rider_id': riderId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<RiderLocation?> streamRiderLocation(String riderId) {
    return _client
        .from('rider_locations')
        .stream(primaryKey: ['rider_id'])
        .eq('rider_id', riderId)
        .map((data) => data.isNotEmpty ? RiderLocation.fromJson(data.first) : null);
  }

  @override
  Future<List<RiderEarning>> getRiderEarnings(String riderId) async {
    final response = await _client
        .from('rider_earnings')
        .select()
        .eq('rider_id', riderId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RiderEarning.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<double> getRiderTotalEarnings(String riderId) async {
    final response = await _client
        .from('rider_earnings')
        .select('net_amount')
        .eq('rider_id', riderId);

    double total = 0.0;
    for (final row in (response as List)) {
      total += (row['net_amount'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }
}
