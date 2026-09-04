import 'dart:async';
import '../../models/notification_domain.dart';

abstract class PushNotificationAdapter {
  /// Request OS notification permission
  Future<bool> requestPermission();

  /// Check current notification permission status
  Future<bool> hasPermission();

  /// Get current device token for remote push notifications
  Future<String?> getDeviceToken();

  /// Stream of refreshed device tokens
  Stream<String> get onTokenRefresh;

  /// Stream of incoming foreground push notification payloads
  Stream<MarketplaceNotification> get onNotificationReceived;

  /// Stream of notification clicks / background opened payloads
  Stream<Map<String, dynamic>> get onNotificationOpenedApp;

  /// Register device token with backend
  Future<void> registerDeviceToken({required String userId, required String role});

  /// Unregister device token on logout
  Future<void> unregisterDeviceToken({required String userId});

  /// Dispose resources
  void dispose();
}

/// Standalone Demo Push Notification Adapter
/// Provides 100% offline simulated push lifecycle without requiring Firebase credentials
class DemoPushNotificationAdapter implements PushNotificationAdapter {
  final _tokenRefreshController = StreamController<String>.broadcast();
  final _notificationReceivedController = StreamController<MarketplaceNotification>.broadcast();
  final _notificationOpenedAppController = StreamController<Map<String, dynamic>>.broadcast();

  bool _isPermitted = true;
  String _demoToken = 'demo_device_token_batkhela_99';

  @override
  Future<bool> requestPermission() async {
    _isPermitted = true;
    return true;
  }

  @override
  Future<bool> hasPermission() async {
    return _isPermitted;
  }

  @override
  Future<String?> getDeviceToken() async {
    return _demoToken;
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<MarketplaceNotification> get onNotificationReceived => _notificationReceivedController.stream;

  @override
  Stream<Map<String, dynamic>> get onNotificationOpenedApp => _notificationOpenedAppController.stream;

  @override
  Future<void> registerDeviceToken({required String userId, required String role}) async {
    // Simulated token registration in Demo Mode
    _demoToken = 'demo_token_${userId}_$role';
    _tokenRefreshController.add(_demoToken);
  }

  @override
  Future<void> unregisterDeviceToken({required String userId}) async {
    // Simulated token cleanup
    _demoToken = 'demo_token_unregistered';
  }

  /// Simulate incoming push notification for testing & UI demonstrations
  void simulateIncomingPush(MarketplaceNotification notification) {
    _notificationReceivedController.add(notification);
  }

  /// Simulate user tapping a background notification
  void simulateNotificationTap(Map<String, dynamic> payload) {
    _notificationOpenedAppController.add(payload);
  }

  @override
  void dispose() {
    _tokenRefreshController.close();
    _notificationReceivedController.close();
    _notificationOpenedAppController.close();
  }
}

/// Firebase Cloud Messaging Push Notification Adapter Template
/// Ready for future production activation with google-services.json
class FcmPushNotificationAdapter implements PushNotificationAdapter {
  final _tokenRefreshController = StreamController<String>.broadcast();
  final _notificationReceivedController = StreamController<MarketplaceNotification>.broadcast();
  final _notificationOpenedAppController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<bool> requestPermission() async {
    // Adapter placeholder for FirebaseMessaging.instance.requestPermission()
    return true;
  }

  @override
  Future<bool> hasPermission() async {
    return true;
  }

  @override
  Future<String?> getDeviceToken() async {
    return null;
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<MarketplaceNotification> get onNotificationReceived => _notificationReceivedController.stream;

  @override
  Stream<Map<String, dynamic>> get onNotificationOpenedApp => _notificationOpenedAppController.stream;

  @override
  Future<void> registerDeviceToken({required String userId, required String role}) async {}

  @override
  Future<void> unregisterDeviceToken({required String userId}) async {}

  @override
  void dispose() {
    _tokenRefreshController.close();
    _notificationReceivedController.close();
    _notificationOpenedAppController.close();
  }
}
