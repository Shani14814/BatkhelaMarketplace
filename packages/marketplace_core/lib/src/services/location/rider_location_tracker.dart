import 'dart:async';
import '../../models/location_domain.dart';
import '../../repositories/rider_repository.dart';
import 'location_service.dart';

/// Central Rider GPS Telemetry Coordinator.
/// Handles throttled location broadcasting, distance filtering, and battery optimization.
class RiderLocationTracker {
  final LocationService locationService;
  final RiderRepository riderRepository;

  StreamSubscription<LocationCoordinates>? _subscription;
  LocationCoordinates? _lastPublishedCoordinates;
  DateTime? _lastPublishedTime;

  String? _activeRiderId;
  bool _isOnline = false;
  LocationTrackerState _state = LocationTrackerState.idle;
  String? _lastError;

  final StreamController<LocationTrackerState> _stateController =
      StreamController<LocationTrackerState>.broadcast();
  final StreamController<LocationCoordinates> _coordinatesController =
      StreamController<LocationCoordinates>.broadcast();

  RiderLocationTracker({
    required this.locationService,
    required this.riderRepository,
  });

  LocationTrackerState get state => _state;
  LocationCoordinates? get lastCoordinates => _lastPublishedCoordinates;
  String? get activeRiderId => _activeRiderId;
  bool get isTracking => _state == LocationTrackerState.tracking;
  String? get lastError => _lastError;

  Stream<LocationTrackerState> get stateStream => _stateController.stream;
  Stream<LocationCoordinates> get coordinatesStream => _coordinatesController.stream;

  /// Starts broadcasting location for the given rider.
  Future<bool> startTracking(
    String riderId, {
    int distanceFilterMeters = 10,
    Duration interval = const Duration(seconds: 10),
  }) async {
    _activeRiderId = riderId;
    _isOnline = true;

    // 1. Verify service & permissions
    final enabled = await locationService.isLocationServiceEnabled();
    if (!enabled) {
      _setError('Location services are disabled on device');
      return false;
    }

    var permission = await locationService.checkPermission();
    if (permission == LocationPermissionState.denied) {
      permission = await locationService.requestPermission();
    }

    if (!permission.isGranted) {
      _setError('Location permission not granted: ${permission.name}');
      return false;
    }

    // 2. Cancel existing subscription if any
    await _subscription?.cancel();
    _subscription = null;

    // 3. Mark rider online in repository
    try {
      await riderRepository.updateOnlineStatus(riderId, true);
    } catch (e) {
      // Non-fatal, continue tracking
    }

    // 4. Start stream listening
    _state = LocationTrackerState.tracking;
    _stateController.add(_state);
    _lastError = null;

    _subscription = locationService
        .streamLocation(
          distanceFilterMeters: distanceFilterMeters,
          interval: interval,
        )
        .listen(
          (coords) => _onLocationReceived(coords, distanceFilterMeters),
          onError: (Object err) {
            _setError(err.toString());
          },
        );

    return true;
  }

  /// Handles incoming coordinates with battery-friendly distance and time throttling.
  Future<void> _onLocationReceived(
    LocationCoordinates coords,
    int distanceFilterMeters,
  ) async {
    if (_activeRiderId == null || !_isOnline) return;

    final now = DateTime.now();
    final lastCoords = _lastPublishedCoordinates;
    final lastTime = _lastPublishedTime;

    // Throttle check: write if first time OR moved >= distanceFilterMeters OR 30s passed
    bool shouldPublish = false;
    if (lastCoords == null || lastTime == null) {
      shouldPublish = true;
    } else {
      final distanceMoved = coords.distanceTo(lastCoords);
      final timeSinceLast = now.difference(lastTime);

      if (distanceMoved >= distanceFilterMeters || timeSinceLast.inSeconds >= 30) {
        shouldPublish = true;
      }
    }

    if (shouldPublish) {
      try {
        await riderRepository.updateTelemetryLocation(
          _activeRiderId!,
          latitude: coords.latitude,
          longitude: coords.longitude,
          heading: coords.heading,
        );
        _lastPublishedCoordinates = coords;
        _lastPublishedTime = now;
        _coordinatesController.add(coords);
      } catch (e) {
        _lastError = 'Telemetry publish failed: $e';
      }
    }
  }

  /// Stops tracking and marks rider offline.
  Future<void> stopTracking() async {
    final riderId = _activeRiderId;
    _isOnline = false;
    _state = LocationTrackerState.idle;
    _stateController.add(_state);

    await _subscription?.cancel();
    _subscription = null;

    if (riderId != null) {
      try {
        await riderRepository.updateOnlineStatus(riderId, false);
      } catch (_) {}
    }

    _activeRiderId = null;
  }

  void _setError(String error) {
    _lastError = error;
    _state = LocationTrackerState.error;
    _stateController.add(_state);
  }

  /// Disposes tracker resources.
  Future<void> dispose() async {
    await stopTracking();
    await _stateController.close();
    await _coordinatesController.close();
  }
}
