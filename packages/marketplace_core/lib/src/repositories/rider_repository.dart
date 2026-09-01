import 'dart:async';
import '../models/rider_profile.dart';
import '../models/delivery.dart';

abstract class RiderRepository {
  Future<RiderProfile?> getRiderProfile(String riderId);
  Future<void> updateOnlineStatus(String riderId, bool isOnline);
  Future<void> updateTelemetryLocation(
    String riderId, {
    required double latitude,
    required double longitude,
    double heading = 0.0,
  });
  Future<List<RiderEarning>> getRiderEarnings(String riderId);
  Future<double> getRiderTotalEarnings(String riderId);

  // Realtime Streams (Phase 7E - Secured by RLS)
  Stream<RiderLocation?> streamRiderLocation(String riderId);
  Stream<RiderProfile?> streamRiderProfile(String riderId);
}
