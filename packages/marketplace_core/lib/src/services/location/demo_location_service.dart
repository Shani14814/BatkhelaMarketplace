import 'dart:async';
import '../../models/location_domain.dart';
import 'location_service.dart';

/// In-memory simulated location provider for Demo Mode and automated testing.
class DemoLocationService implements LocationService {
  LocationPermissionState _permission = LocationPermissionState.granted;
  bool _serviceEnabled = true;

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  static final List<LocationCoordinates> _batkhelaRouteWaypoints = [
    LocationCoordinates(
      latitude: 34.6186,
      longitude: 71.9723,
      heading: 45.0,
      accuracy: 3.5,
      speed: 8.5,
      timestamp: _epoch,
    ),
    LocationCoordinates(
      latitude: 34.6198,
      longitude: 71.9739,
      heading: 52.0,
      accuracy: 3.0,
      speed: 9.0,
      timestamp: _epoch,
    ),
    LocationCoordinates(
      latitude: 34.6212,
      longitude: 71.9758,
      heading: 60.0,
      accuracy: 4.0,
      speed: 7.5,
      timestamp: _epoch,
    ),
    LocationCoordinates(
      latitude: 34.6225,
      longitude: 71.9780,
      heading: 65.0,
      accuracy: 3.2,
      speed: 8.0,
      timestamp: _epoch,
    ),
    LocationCoordinates(
      latitude: 34.6240,
      longitude: 71.9805,
      heading: 70.0,
      accuracy: 3.8,
      speed: 6.0,
      timestamp: _epoch,
    ),
  ];

  int _waypointIndex = 0;

  void setPermission(LocationPermissionState state) {
    _permission = state;
  }

  void setServiceEnabled(bool enabled) {
    _serviceEnabled = enabled;
  }

  @override
  Future<LocationPermissionState> checkPermission() async {
    return _permission;
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    if (_permission == LocationPermissionState.permanentlyDenied) {
      return LocationPermissionState.permanentlyDenied;
    }
    _permission = LocationPermissionState.granted;
    return _permission;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return _serviceEnabled;
  }

  @override
  Future<LocationCoordinates?> getCurrentLocation() async {
    if (!_serviceEnabled || !_permission.isGranted) return null;
    final wp = _batkhelaRouteWaypoints[_waypointIndex % _batkhelaRouteWaypoints.length];
    return wp.copyWith(timestamp: DateTime.now());
  }

  @override
  Stream<LocationCoordinates> streamLocation({
    int distanceFilterMeters = 10,
    Duration interval = const Duration(seconds: 10),
  }) {
    late StreamController<LocationCoordinates> controller;
    Timer? timer;

    void emitNext() {
      if (!_serviceEnabled || !_permission.isGranted) return;
      final wp = _batkhelaRouteWaypoints[_waypointIndex % _batkhelaRouteWaypoints.length];
      _waypointIndex++;
      if (!controller.isClosed) {
        controller.add(wp.copyWith(timestamp: DateTime.now()));
      }
    }

    controller = StreamController<LocationCoordinates>(
      onListen: () {
        emitNext();
        timer = Timer.periodic(interval, (_) => emitNext());
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }
}
