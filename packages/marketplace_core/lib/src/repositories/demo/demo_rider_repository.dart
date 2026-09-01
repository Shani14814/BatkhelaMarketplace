import '../../models/rider_profile.dart';
import '../rider_repository.dart';

class DemoRiderRepository implements RiderRepository {
  final RiderProfile _profile = const RiderProfile(
    id: 'rider-prof-1',
    userId: 'demo-role-rider',
    vehicleType: 'Honda CG 125',
    vehicleNumber: 'MKN-4821',
    cnicNumber: '15402-1234567-1',
    licenseNumber: 'BK-DL-88219',
    isVerified: true,
    rating: 4.9,
    totalDeliveries: 148,
    fullName: 'Salman Khan',
    phone: '+92 345 3333333',
  );

  bool _isOnline = true;
  double _currentLat = 34.6185;
  double _currentLng = 71.9723;
  double _currentHeading = 45.0;

  final List<RiderEarning> _earnings = [
    RiderEarning(
      id: 'earn-1',
      riderId: 'rider-prof-1',
      orderId: 'ord-1001',
      deliveryFee: 120.0,
      tips: 50.0,
      bonus: 30.0,
      netEarning: 200.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RiderEarning(
      id: 'earn-2',
      riderId: 'rider-prof-1',
      orderId: 'ord-1002',
      deliveryFee: 100.0,
      tips: 0.0,
      bonus: 20.0,
      netEarning: 120.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  @override
  Future<RiderProfile?> getRiderProfile(String riderId) async {
    return _profile;
  }

  @override
  Future<void> updateOnlineStatus(String riderId, bool isOnline) async {
    _isOnline = isOnline;
  }

  @override
  Future<void> updateTelemetryLocation(
    String riderId, {
    required double latitude,
    required double longitude,
    double heading = 0.0,
  }) async {
    _currentLat = latitude;
    _currentLng = longitude;
    _currentHeading = heading;
  }

  @override
  Future<List<RiderEarning>> getRiderEarnings(String riderId) async {
    return List.unmodifiable(_earnings);
  }

  @override
  Future<double> getRiderTotalEarnings(String riderId) async {
    double total = 0.0;
    for (final e in _earnings) {
      total += e.netEarning;
    }
    return total;
  }

  // Getters for inspection in tests
  bool get isOnline => _isOnline;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  double get currentHeading => _currentHeading;
}
