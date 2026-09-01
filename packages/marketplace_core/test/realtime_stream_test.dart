import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  setUp(() {
    MarketplaceDataService.instance.initialize(isDemoMode: true);
    RealtimeSubscriptionManager.instance.cancelAll();
  });

  tearDown(() {
    RealtimeSubscriptionManager.instance.cancelAll();
  });

  group('Phase 7E — Realtime Subscription & Stream Architecture Tests', () {
    test('Customer order realtime stream emits updates on new order placement', () async {
      final customerRepo = MarketplaceDataService.instance.customerRepo;
      final stream = customerRepo.streamCustomerOrders('demo-user-1');

      final emittedStates = <List<MarketplaceOrder>>[];
      final sub = stream.listen((orders) {
        emittedStates.add(orders);
      });
      RealtimeSubscriptionManager.instance.register('customer_orders_sub', sub);

      // Allow initial stream emission
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Place a new order
      final newOrder = MarketplaceOrder(
        id: '',
        customerId: 'demo-user-1',
        vendorId: 'store-1',
        subtotal: 1200.0,
        totalAmount: 1350.0,
        status: OrderStatus.placed,
        deliveryAddress: 'Batkhela Main Bazaar',
        createdAt: DateTime.now(),
      );
      await customerRepo.createOrder(newOrder);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emittedStates.length, greaterThanOrEqualTo(2));
      expect(emittedStates.last.any((o) => o.vendorId == 'store-1'), isTrue);
    });

    test('Vendor order realtime stream emits on status transition', () async {
      final vendorRepo = MarketplaceDataService.instance.vendorRepo;
      final stream = vendorRepo.streamVendorOrders('store-1');

      final emittedOrders = <List<MarketplaceOrder>>[];
      final sub = stream.listen((orders) {
        emittedOrders.add(orders);
      });
      RealtimeSubscriptionManager.instance.register('vendor_orders_sub', sub);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Transition order status
      await vendorRepo.updateOrderStatus('ord-v-101', OrderStatus.preparing);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emittedOrders.length, greaterThanOrEqualTo(2));
      final updatedOrder = emittedOrders.last.firstWhere((o) => o.id == 'ord-v-101');
      expect(updatedOrder.status, OrderStatus.preparing);
    });

    test('Vendor profile stream emits when vendor toggles store open/closed', () async {
      final vendorRepo = MarketplaceDataService.instance.vendorRepo;
      final stream = vendorRepo.streamVendorProfile('store-1');

      final emittedProfiles = <Vendor?>[];
      final sub = stream.listen((profile) {
        emittedProfiles.add(profile);
      });
      RealtimeSubscriptionManager.instance.register('vendor_profile_sub', sub);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await vendorRepo.updateStoreStatus('store-1', isOpen: false);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emittedProfiles.length, greaterThanOrEqualTo(2));
      expect(emittedProfiles.last?.isOpen, isFalse);
    });

    test('Rider telemetry location stream emits updates securely', () async {
      final riderRepo = MarketplaceDataService.instance.riderRepo;
      final stream = riderRepo.streamRiderLocation('rider-prof-1');

      final locations = <RiderLocation?>[];
      final sub = stream.listen((loc) {
        locations.add(loc);
      });
      RealtimeSubscriptionManager.instance.register('rider_telemetry_sub', sub);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await riderRepo.updateTelemetryLocation(
        'rider-prof-1',
        latitude: 34.6210,
        longitude: 71.9750,
        heading: 180.0,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(locations.length, greaterThanOrEqualTo(2));
      expect(locations.last?.latitude, 34.6210);
      expect(locations.last?.longitude, 71.9750);
      expect(locations.last?.heading, 180.0);
    });

    test('Rider delivery stream emits on accepting and updating delivery task', () async {
      final deliveryRepo = MarketplaceDataService.instance.deliveryRepo;
      final stream = deliveryRepo.streamRiderDeliveries('demo-role-rider');

      final emittedTasks = <List<DeliveryTask>>[];
      final sub = stream.listen((tasks) {
        emittedTasks.add(tasks);
      });
      RealtimeSubscriptionManager.instance.register('rider_deliveries_sub', sub);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await deliveryRepo.updateDeliveryStatus('del-101', DeliveryStatus.delivered);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emittedTasks.length, greaterThanOrEqualTo(2));
      final completedTask = emittedTasks.last.firstWhere((t) => t.id == 'del-101');
      expect(completedTask.status, DeliveryStatus.delivered);
      expect(completedTask.deliveredTime, isNotNull);
    });

    test('Admin pending vendor and rider streams emit on approval actions', () async {
      final adminRepo = MarketplaceDataService.instance.adminRepo;
      final vendorStream = adminRepo.streamPendingVendors();
      final riderStream = adminRepo.streamPendingRiderApplications();

      final pendingVendors = <List<Vendor>>[];
      final pendingRiders = <List<RiderProfile>>[];

      final sub1 = vendorStream.listen((list) => pendingVendors.add(list));
      final sub2 = riderStream.listen((list) => pendingRiders.add(list));

      RealtimeSubscriptionManager.instance.register('admin_vendors_sub', sub1);
      RealtimeSubscriptionManager.instance.register('admin_riders_sub', sub2);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await adminRepo.updateVendorApproval('vendor-pending-1', true);
      await adminRepo.updateRiderApproval('rider-app-1', true);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(pendingVendors.last.any((v) => v.id == 'vendor-pending-1'), isFalse);
      expect(pendingRiders.last.any((r) => r.id == 'rider-app-1'), isFalse);
    });

    test('RealtimeSubscriptionManager lifecycle and safe disposal', () async {
      final manager = RealtimeSubscriptionManager.instance;
      expect(manager.activeCount, 0);

      final controller = StreamController<int>.broadcast();
      final sub1 = controller.stream.listen((_) {});
      final sub2 = controller.stream.listen((_) {});
      final sub3 = controller.stream.listen((_) {});

      manager.register('customer_order_1', sub1);
      manager.register('customer_order_2', sub2);
      manager.register('rider_loc_1', sub3);

      expect(manager.activeCount, 3);
      expect(manager.isActive('customer_order_1'), isTrue);

      // Cancel by prefix
      await manager.cancelByPrefix('customer_');
      expect(manager.activeCount, 1);
      expect(manager.isActive('customer_order_1'), isFalse);
      expect(manager.isActive('rider_loc_1'), isTrue);

      // Cancel all
      await manager.cancelAll();
      expect(manager.activeCount, 0);
      await controller.close();
    });

    test('AuthService signOut and signInDemo clean up all realtime subscriptions', () async {
      final manager = RealtimeSubscriptionManager.instance;
      final controller = StreamController<int>.broadcast();
      final sub = controller.stream.listen((_) {});

      manager.register('active_telemetry', sub);
      expect(manager.activeCount, 1);

      // Sign Out
      await AuthService.instance.signOut();
      expect(manager.activeCount, 0);

      // Re-register and test role switch
      final sub2 = controller.stream.listen((_) {});
      manager.register('active_telemetry_2', sub2);
      expect(manager.activeCount, 1);

      await AuthService.instance.signInDemo(UserRole.vendor);
      expect(manager.activeCount, 0);

      await controller.close();
    });
  });
}
