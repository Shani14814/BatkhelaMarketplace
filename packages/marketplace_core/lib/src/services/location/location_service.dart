import 'dart:async';
import '../../models/location_domain.dart';

/// Clean Architecture Location Service contract.
abstract class LocationService {
  /// Checks current system permission status.
  Future<LocationPermissionState> checkPermission();

  /// Prompts user for location permission.
  Future<LocationPermissionState> requestPermission();

  /// Checks if hardware GPS is enabled on device.
  Future<bool> isLocationServiceEnabled();

  /// Fetches a single current location snapshot.
  Future<LocationCoordinates?> getCurrentLocation();

  /// Streams location updates with battery-friendly distance filtering.
  Stream<LocationCoordinates> streamLocation({
    int distanceFilterMeters = 10,
    Duration interval = const Duration(seconds: 10),
  });
}
