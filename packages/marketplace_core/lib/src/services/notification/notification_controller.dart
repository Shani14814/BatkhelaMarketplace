import 'dart:async';
import '../../models/notification_domain.dart';
import '../../repositories/notification_repository.dart';
import 'push_notification_adapter.dart';

class NotificationController {
  final NotificationRepository repository;
  final PushNotificationAdapter pushAdapter;

  final _inAppAlertController = StreamController<MarketplaceNotification>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();

  StreamSubscription<List<MarketplaceNotification>>? _notificationSub;
  StreamSubscription<MarketplaceNotification>? _pushReceivedSub;
  StreamSubscription<Map<String, dynamic>>? _pushOpenedSub;

  int _currentUnreadCount = 0;
  String? _currentUserId;
  String? _currentRole;
  bool _isDisposed = false;

  NotificationController({
    required this.repository,
    required this.pushAdapter,
  });

  int get currentUnreadCount => _currentUnreadCount;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  Stream<MarketplaceNotification> get inAppAlertStream => _inAppAlertController.stream;
  Stream<Map<String, dynamic>> get onNotificationOpenedApp => pushAdapter.onNotificationOpenedApp;

  /// Initialize notification tracking for an authenticated user session
  Future<void> initSession({required String userId, required String role}) async {
    if (_isDisposed) return;
    await stopSession();

    _currentUserId = userId;
    _currentRole = role;

    // Register push device token
    await pushAdapter.registerDeviceToken(userId: userId, role: role);

    // Initial unread count
    _currentUnreadCount = await repository.getUnreadCount(userId: userId, role: role);
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(_currentUnreadCount);
    }

    // Listen to repository notification stream
    _notificationSub = repository
        .streamNotifications(userId: userId, role: role)
        .listen((notifications) {
      final unread = notifications.where((n) => !n.isRead).length;
      if (unread != _currentUnreadCount) {
        _currentUnreadCount = unread;
        if (!_unreadCountController.isClosed) {
          _unreadCountController.add(_currentUnreadCount);
        }
      }
    });

    // Listen to incoming push notifications
    _pushReceivedSub = pushAdapter.onNotificationReceived.listen((notification) {
      if (!_inAppAlertController.isClosed) {
        _inAppAlertController.add(notification);
      }
    });
  }

  /// Trigger a contextual in-app alert and save to repository
  Future<MarketplaceNotification> dispatchNotification({
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? targetRole,
    String? orderId,
    String? deliveryId,
    Map<String, dynamic> payload = const {},
  }) async {
    final userId = _currentUserId ?? 'usr_guest';
    final notification = MarketplaceNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      priority: priority,
      targetRole: targetRole ?? _currentRole,
      orderId: orderId,
      deliveryId: deliveryId,
      payload: payload,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final saved = await repository.sendNotification(notification);
    if (!_inAppAlertController.isClosed) {
      _inAppAlertController.add(saved);
    }
    return saved;
  }

  /// Mark specific notification as read
  Future<void> markAsRead(String notificationId) async {
    await repository.markAsRead(notificationId);
    if (_currentUserId != null) {
      _currentUnreadCount = await repository.getUnreadCount(
        userId: _currentUserId!,
        role: _currentRole,
      );
      if (!_unreadCountController.isClosed) {
        _unreadCountController.add(_currentUnreadCount);
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId != null) {
      await repository.markAllAsRead(
        userId: _currentUserId!,
        role: _currentRole,
      );
      _currentUnreadCount = 0;
      if (!_unreadCountController.isClosed) {
        _unreadCountController.add(0);
      }
    }
  }

  /// Fetch full notification list
  Future<List<MarketplaceNotification>> getNotifications() async {
    if (_currentUserId == null) return [];
    return repository.getNotifications(
      userId: _currentUserId!,
      role: _currentRole,
    );
  }

  /// Tear down user session on logout or role change
  Future<void> stopSession() async {
    await _notificationSub?.cancel();
    await _pushReceivedSub?.cancel();
    await _pushOpenedSub?.cancel();
    _notificationSub = null;
    _pushReceivedSub = null;
    _pushOpenedSub = null;

    if (_currentUserId != null) {
      await pushAdapter.unregisterDeviceToken(userId: _currentUserId!);
    }

    _currentUserId = null;
    _currentRole = null;
    _currentUnreadCount = 0;
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(0);
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await stopSession();
    if (!_inAppAlertController.isClosed) {
      await _inAppAlertController.close();
    }
    if (!_unreadCountController.isClosed) {
      await _unreadCountController.close();
    }
    pushAdapter.dispose();
  }
}
