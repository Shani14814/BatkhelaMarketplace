import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  group('Phase 7H — Notification Domain & Model Tests', () {
    test('MarketplaceNotification JSON serialization & deserialization', () {
      final now = DateTime.now();
      final notification = MarketplaceNotification(
        id: 'notif_test_1',
        userId: 'usr_test_1',
        title: 'Order Delivered 🎉',
        body: 'Your food is delivered.',
        type: NotificationType.orderDelivered,
        priority: NotificationPriority.high,
        targetRole: 'customer',
        orderId: 'ord_1001',
        deliveryId: 'del_1001',
        payload: {'route': '/customer/orders'},
        isRead: false,
        createdAt: now,
      );

      final json = notification.toJson();
      expect(json['id'], 'notif_test_1');
      expect(json['type'], 'order_delivered');
      expect(json['priority'], 'high');
      expect(json['target_role'], 'customer');
      expect(json['order_id'], 'ord_1001');

      final fromJson = MarketplaceNotification.fromJson(json);
      expect(fromJson.id, notification.id);
      expect(fromJson.type, NotificationType.orderDelivered);
      expect(fromJson.priority, NotificationPriority.high);
      expect(fromJson.targetRole, 'customer');
      expect(fromJson.isRead, false);
    });

    test('NotificationType fromString and toDbString roundtrip', () {
      for (final type in NotificationType.values) {
        final dbStr = type.toDbString();
        final parsed = NotificationType.fromString(dbStr);
        expect(parsed, type);
      }
    });

    test('NotificationPriority fromString and toDbString roundtrip', () {
      for (final priority in NotificationPriority.values) {
        final dbStr = priority.toDbString();
        final parsed = NotificationPriority.fromString(dbStr);
        expect(parsed, priority);
      }
    });
  });

  group('Phase 7H — DemoNotificationRepository Tests', () {
    late DemoNotificationRepository repository;

    setUp(() {
      repository = DemoNotificationRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('Returns seeded notifications for specific role', () async {
      final customerNotifs = await repository.getNotifications(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      expect(customerNotifs.isNotEmpty, true);
      expect(customerNotifs.every((n) => n.targetRole == 'customer'), true);

      final vendorNotifs = await repository.getNotifications(
        userId: 'usr_vendor_1',
        role: 'vendor',
      );
      expect(vendorNotifs.isNotEmpty, true);
      expect(vendorNotifs.every((n) => n.targetRole == 'vendor'), true);
    });

    test('Unread count calculation and markAsRead', () async {
      final initialUnread = await repository.getUnreadCount(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      expect(initialUnread, greaterThan(0));

      final customerNotifs = await repository.getNotifications(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      final unreadItem = customerNotifs.firstWhere((n) => !n.isRead);

      await repository.markAsRead(unreadItem.id);

      final updatedUnread = await repository.getUnreadCount(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      expect(updatedUnread, initialUnread - 1);
    });

    test('markAllAsRead clears unread count for role', () async {
      await repository.markAllAsRead(
        userId: 'usr_customer_1',
        role: 'customer',
      );

      final count = await repository.getUnreadCount(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      expect(count, 0);
    });

    test('sendNotification dispatches new notification to stream', () async {
      final newNotif = MarketplaceNotification(
        id: 'notif_live_99',
        userId: 'usr_customer_1',
        title: 'New Promo Discount',
        body: 'Get 20% off at Shinwari Tikka',
        type: NotificationType.systemAlert,
        targetRole: 'customer',
        createdAt: DateTime.now(),
      );

      await repository.sendNotification(newNotif);

      final notifs = await repository.getNotifications(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      expect(notifs.any((n) => n.id == 'notif_live_99'), true);
    });

    test('deleteNotification removes item', () async {
      final notifs = await repository.getNotifications(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      final targetId = notifs.first.id;

      await repository.deleteNotification(targetId);

      final updated = await repository.getNotifications(
        userId: 'usr_customer_1',
        role: 'customer',
      );
      expect(updated.any((n) => n.id == targetId), false);
    });
  });

  group('Phase 7H — NotificationController & Push Adapter Tests', () {
    late DemoNotificationRepository repository;
    late DemoPushNotificationAdapter pushAdapter;
    late NotificationController controller;

    setUp(() {
      repository = DemoNotificationRepository();
      pushAdapter = DemoPushNotificationAdapter();
      controller = NotificationController(
        repository: repository,
        pushAdapter: pushAdapter,
      );
    });

    tearDown(() async {
      await controller.dispose();
      repository.dispose();
    });

    test('Initializes session and receives unread count', () async {
      await controller.initSession(userId: 'usr_customer_1', role: 'customer');
      expect(controller.currentUnreadCount, greaterThan(0));
    });

    test('dispatchNotification adds notification and updates unread count', () async {
      await controller.initSession(userId: 'usr_customer_1', role: 'customer');
      final initialUnread = controller.currentUnreadCount;

      await controller.dispatchNotification(
        title: 'Test Title',
        body: 'Test Body',
        type: NotificationType.orderPlaced,
      );

      // Wait a moment for stream emission
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.currentUnreadCount, initialUnread + 1);
    });

    test('markAllAsRead resets controller unread count', () async {
      await controller.initSession(userId: 'usr_customer_1', role: 'customer');
      await controller.markAllAsRead();
      expect(controller.currentUnreadCount, 0);
    });

    test('Tear down session cleans up user state', () async {
      await controller.initSession(userId: 'usr_customer_1', role: 'customer');
      await controller.stopSession();
      expect(controller.currentUnreadCount, 0);
    });
  });

  group('Phase 7H — Data Hub Integration Tests', () {
    test('MarketplaceDataService registers notification repository and controller', () {
      final dataService = MarketplaceDataService.instance;
      expect(dataService.notificationRepo, isNotNull);
      expect(dataService.notificationController, isNotNull);
      expect(dataService.pushAdapter, isNotNull);

      // Switch to Supabase mode
      dataService.initialize(isDemoMode: false);
      expect(dataService.notificationRepo, isA<SupabaseNotificationRepository>());

      // Switch back to Demo mode
      dataService.initialize(isDemoMode: true);
      expect(dataService.notificationRepo, isA<DemoNotificationRepository>());
    });
  });
}
