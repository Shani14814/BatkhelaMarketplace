import 'dart:async';
import '../../models/notification_domain.dart';
import '../notification_repository.dart';

class DemoNotificationRepository implements NotificationRepository {
  final List<MarketplaceNotification> _notifications = [];
  final _streamController = StreamController<List<MarketplaceNotification>>.broadcast();

  DemoNotificationRepository() {
    _seedDemoNotifications();
  }

  void _seedDemoNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      // Customer Notifications
      MarketplaceNotification(
        id: 'notif_cust_1',
        userId: 'usr_customer_1',
        title: 'Order Delivered 🎉',
        body: 'Your order #1001 from Shinwari Tikka & Karahi has been delivered. Enjoy your meal!',
        type: NotificationType.orderDelivered,
        priority: NotificationPriority.normal,
        targetRole: 'customer',
        orderId: 'ord_1001',
        payload: {'route': '/customer/orders', 'order_id': 'ord_1001'},
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      MarketplaceNotification(
        id: 'notif_cust_2',
        userId: 'usr_customer_1',
        title: 'Rider Out for Delivery 🛵',
        body: 'Rider Tariq Khan is on the way to your delivery address in Batkhela.',
        type: NotificationType.orderOutForDelivery,
        priority: NotificationPriority.high,
        targetRole: 'customer',
        orderId: 'ord_1001',
        payload: {'route': '/customer/orders', 'order_id': 'ord_1001'},
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 35)),
        readAt: now.subtract(const Duration(minutes: 30)),
      ),
      MarketplaceNotification(
        id: 'notif_cust_3',
        userId: 'usr_customer_1',
        title: 'Order Confirmed ✅',
        body: 'Shinwari Tikka & Karahi accepted your order #1001 and is preparing your food.',
        type: NotificationType.orderAccepted,
        priority: NotificationPriority.normal,
        targetRole: 'customer',
        orderId: 'ord_1001',
        payload: {'route': '/customer/orders', 'order_id': 'ord_1001'},
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 50)),
        readAt: now.subtract(const Duration(minutes: 45)),
      ),

      // Vendor Notifications
      MarketplaceNotification(
        id: 'notif_vend_1',
        userId: 'usr_vendor_1',
        title: '🔔 New Order Received! (Rs. 1,450)',
        body: 'New order #1001 received with 2 items from Main Bazaar.',
        type: NotificationType.newIncomingOrder,
        priority: NotificationPriority.urgent,
        targetRole: 'vendor',
        orderId: 'ord_1001',
        payload: {'route': '/vendor/orders', 'order_id': 'ord_1001'},
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 48)),
      ),
      MarketplaceNotification(
        id: 'notif_vend_2',
        userId: 'usr_vendor_1',
        title: 'Rider Assigned for Pickup',
        body: 'Rider Tariq Khan has been assigned to pick up order #1001.',
        type: NotificationType.riderArrived,
        priority: NotificationPriority.normal,
        targetRole: 'vendor',
        orderId: 'ord_1001',
        payload: {'route': '/vendor/orders', 'order_id': 'ord_1001'},
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 40)),
        readAt: now.subtract(const Duration(minutes: 38)),
      ),

      // Rider Notifications
      MarketplaceNotification(
        id: 'notif_rider_1',
        userId: 'usr_rider_1',
        title: '🛵 New Delivery Offer! (Rs. 180)',
        body: 'Pickup at Shinwari Tikka → Dropoff at GT Road Batkhela.',
        type: NotificationType.deliveryOffer,
        priority: NotificationPriority.urgent,
        targetRole: 'rider',
        deliveryId: 'del_1001',
        orderId: 'ord_1001',
        payload: {'route': '/rider/deliveries', 'delivery_id': 'del_1001'},
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 42)),
      ),
      MarketplaceNotification(
        id: 'notif_rider_2',
        userId: 'usr_rider_1',
        title: 'Store Order Packed & Ready',
        body: 'Shinwari Tikka has packed order #1001. Please proceed to pickup counter.',
        type: NotificationType.orderReadyForPickup,
        priority: NotificationPriority.high,
        targetRole: 'rider',
        deliveryId: 'del_1001',
        orderId: 'ord_1001',
        payload: {'route': '/rider/deliveries', 'delivery_id': 'del_1001'},
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 36)),
        readAt: now.subtract(const Duration(minutes: 35)),
      ),

      // Admin Notifications
      MarketplaceNotification(
        id: 'notif_admin_1',
        userId: 'usr_admin_1',
        title: 'New Vendor Application 📋',
        body: 'Swat Valley Bakers submitted merchant KYC verification documents.',
        type: NotificationType.newVendorKyc,
        priority: NotificationPriority.high,
        targetRole: 'admin',
        payload: {'route': '/admin/vendors'},
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MarketplaceNotification(
        id: 'notif_admin_2',
        userId: 'usr_admin_1',
        title: 'New Rider Onboarding 🛵',
        body: 'Rider Kamran Khan submitted license and CNIC for fleet verification.',
        type: NotificationType.newRiderKyc,
        priority: NotificationPriority.normal,
        targetRole: 'admin',
        payload: {'route': '/admin/riders'},
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  void _notifyListeners() {
    _streamController.add(List.unmodifiable(_notifications));
  }

  @override
  Future<List<MarketplaceNotification>> getNotifications({
    required String userId,
    String? role,
  }) async {
    return _notifications.where((n) {
      if (role != null && n.targetRole != null && n.targetRole != role) {
        return false;
      }
      return n.userId == userId || (role != null && n.targetRole == role);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<int> getUnreadCount({
    required String userId,
    String? role,
  }) async {
    final list = await getNotifications(userId: userId, role: role);
    return list.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      _notifyListeners();
    }
  }

  @override
  Future<void> markAllAsRead({
    required String userId,
    String? role,
  }) async {
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      final matchesUser = n.userId == userId || (role != null && n.targetRole == role);
      if (matchesUser && !n.isRead) {
        _notifications[i] = n.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
    _notifyListeners();
  }

  @override
  Future<MarketplaceNotification> sendNotification(MarketplaceNotification notification) async {
    _notifications.insert(0, notification);
    _notifyListeners();
    return notification;
  }

  @override
  Stream<List<MarketplaceNotification>> streamNotifications({
    required String userId,
    String? role,
  }) {
    // Return a stream that immediately emits current list and updates on changes
    return Stream<List<MarketplaceNotification>>.multi((controller) {
      void emitFiltered() {
        final list = _notifications.where((n) {
          if (role != null && n.targetRole != null && n.targetRole != role) {
            return false;
          }
          return n.userId == userId || (role != null && n.targetRole == role);
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(list);
      }

      emitFiltered();
      final sub = _streamController.stream.listen((_) => emitFiltered());
      controller.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }

  void dispose() {
    _streamController.close();
  }
}
