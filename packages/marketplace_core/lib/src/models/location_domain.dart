import 'dart:math' as math;

/// Geographic coordinates with telemetry details.
class LocationCoordinates {
  final double latitude;
  final double longitude;
  final double heading;
  final double accuracy;
  final double speed;
  final double altitude;
  final DateTime timestamp;

  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.accuracy = 5.0,
    this.speed = 0.0,
    this.altitude = 0.0,
    required this.timestamp,
  });

  /// Default center coordinates for Batkhela Bazaar Hub
  static LocationCoordinates get defaultBatkhelaCenter => LocationCoordinates(
    latitude: 34.6186,
    longitude: 71.9723,
    heading: 0.0,
    accuracy: 5.0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Computes distance in meters to another coordinate using the Haversine formula.
  double distanceTo(LocationCoordinates other) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 5.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'accuracy': accuracy,
      'speed': speed,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  LocationCoordinates copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? accuracy,
    double? speed,
    double? altitude,
    DateTime? timestamp,
  }) {
    return LocationCoordinates(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      altitude: altitude ?? this.altitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Status of OS Location Permissions.
enum LocationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  unknown;

  bool get isGranted => this == LocationPermissionState.granted;
}

/// Operational state of location tracker.
enum LocationTrackerState {
  idle,
  tracking,
  paused,
  error,
}
