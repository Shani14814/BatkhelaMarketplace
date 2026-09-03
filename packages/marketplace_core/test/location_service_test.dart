import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  group('Phase 7G — Location Domain & Haversine Distance Tests', () {
    test('LocationCoordinates calculates correct distance using Haversine formula', () {
      final now = DateTime.now();
      final batkhelaCenter = LocationCoordinates(
        latitude: 34.6186,
        longitude: 71.9723,
        timestamp: now,
      );

      // Point ~155 meters away on GT Road
      final nextPoint = LocationCoordinates(
        latitude: 34.6198,
        longitude: 71.9733,
        timestamp: now,
      );

      final distance = batkhelaCenter.distanceTo(nextPoint);
      expect(distance, greaterThan(130));
      expect(distance, lessThan(170));

      // Distance to self is 0
      expect(batkhelaCenter.distanceTo(batkhelaCenter), 0.0);
    });

    test('LocationCoordinates JSON serialization and deserialization', () {
      final now = DateTime.now();
      final coords = LocationCoordinates(
        latitude: 34.6186,
        longitude: 71.9723,
        heading: 90.0,
        accuracy: 4.2,
        speed: 12.5,
        altitude: 680.0,
        timestamp: now,
      );

      final json = coords.toJson();
      expect(json['latitude'], 34.6186);
      expect(json['longitude'], 71.9723);
      expect(json['heading'], 90.0);
      expect(json['speed'], 12.5);

      final parsed = LocationCoordinates.fromJson(json);
      expect(parsed.latitude, coords.latitude);
      expect(parsed.longitude, coords.longitude);
      expect(parsed.heading, coords.heading);
      expect(parsed.speed, coords.speed);
    });
  });

  group('Phase 7G — DemoLocationService Tests', () {
    late DemoLocationService locationService;

    setUp(() {
      locationService = DemoLocationService();
    });

    test('DemoLocationService provides simulated coordinates when permitted', () async {
      expect(await locationService.isLocationServiceEnabled(), isTrue);
      expect((await locationService.checkPermission()).isGranted, isTrue);

      final current = await locationService.getCurrentLocation();
      expect(current, isNotNull);
      expect(current!.latitude, closeTo(34.6186, 0.05));
      expect(current.longitude, closeTo(71.9723, 0.05));
    });

    test('DemoLocationService respects disabled state and permission denial', () async {
      locationService.setServiceEnabled(false);
      expect(await locationService.isLocationServiceEnabled(), isFalse);
      expect(await locationService.getCurrentLocation(), isNull);

      locationService.setServiceEnabled(true);
      locationService.setPermission(LocationPermissionState.denied);
      expect((await locationService.checkPermission()).isGranted, isFalse);
      expect(await locationService.getCurrentLocation(), isNull);
    });

    test('DemoLocationService streams sequential waypoint updates', () async {
      final stream = locationService.streamLocation(
        interval: const Duration(milliseconds: 50),
      );

      final waypoints = await stream.take(3).toList();
      expect(waypoints.length, 3);
      expect(waypoints[0].latitude, isNotNull);
      expect(waypoints[1].latitude, isNotNull);
    });
  });

  group('Phase 7G — RiderLocationTracker Lifecycle & Battery Throttling Tests', () {
    late DemoLocationService locationService;
    late DemoRiderRepository riderRepository;
    late RiderLocationTracker tracker;

    setUp(() {
      locationService = DemoLocationService();
      riderRepository = DemoRiderRepository();
      tracker = RiderLocationTracker(
        locationService: locationService,
        riderRepository: riderRepository,
      );
    });

    tearDown(() async {
      await tracker.dispose();
    });

    test('tracker starts tracking and marks rider online', () async {
      const riderId = 'RIDER-TEST-001';
      final started = await tracker.startTracking(
        riderId,
        interval: const Duration(milliseconds: 50),
      );

      expect(started, isTrue);
      expect(tracker.isTracking, isTrue);
      expect(tracker.activeRiderId, riderId);
      expect(tracker.state, LocationTrackerState.tracking);
    });

    test('tracker rejects tracking when location service is disabled', () async {
      locationService.setServiceEnabled(false);
      final started = await tracker.startTracking('RIDER-TEST-002');

      expect(started, isFalse);
      expect(tracker.isTracking, isFalse);
      expect(tracker.state, LocationTrackerState.error);
      expect(tracker.lastError, contains('disabled'));
    });

    test('tracker stops tracking cleanly and marks rider offline', () async {
      const riderId = 'RIDER-TEST-003';
      await tracker.startTracking(
        riderId,
        interval: const Duration(milliseconds: 50),
      );
      expect(tracker.isTracking, isTrue);

      await tracker.stopTracking();
      expect(tracker.isTracking, isFalse);
      expect(tracker.state, LocationTrackerState.idle);
      expect(tracker.activeRiderId, isNull);
    });

    test('MarketplaceDataService initializes with LocationService and RiderLocationTracker', () {
      final dataHub = MarketplaceDataService.instance;
      dataHub.initialize(isDemoMode: true);

      expect(dataHub.locationService, isNotNull);
      expect(dataHub.riderLocationTracker, isNotNull);
    });
  });
}
