import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../data/customer_demo_data.dart';
import '../data/vendor_demo_data.dart';
import '../data/rider_demo_data.dart';

/// Synchronizes Customer, Vendor, and Rider state with the live Hostinger MySQL Database
class LiveSyncController extends ChangeNotifier {
  static final LiveSyncController instance = LiveSyncController._();
  LiveSyncController._();

  Timer? _pollTimer;
  bool _isSyncing = false;
  bool _initialized = false;

  void startLiveSync() {
    if (_initialized || HostingerApiClient.instance.isTestEnvironment) return;
    _initialized = true;
    unawaited(syncNow());
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      unawaited(syncNow());
    });
  }

  void stopLiveSync() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _initialized = false;
  }

  Future<void> syncNow() async {
    if (_isSyncing || HostingerApiClient.instance.isTestEnvironment) return;
    _isSyncing = true;
    try {
      var state = await HostingerApiClient.instance.fetchState();
      if (state == null) return;

      final isSeeded = state['seeded'] == true;
      if (!isSeeded) {
        // Seed initial 16 Batkhela stores, products, and orders into MySQL
        final storesPayload = <Map<String, dynamic>>[];
        final productsPayload = <Map<String, dynamic>>[];

        for (var i = 0; i < CustomerDemoData.stores.length; i++) {
          final s = CustomerDemoData.stores[i];
          storesPayload.add(s.toJson(sortOrder: i));
          for (final p in s.products) {
            productsPayload.add(p.toJson());
          }
        }

        final ordersPayload = VendorDemoController.instance.orders
            .map((o) => o.toJson())
            .toList();

        await HostingerApiClient.instance.seedInitialData(
          stores: storesPayload,
          products: productsPayload,
          orders: ordersPayload,
        );
        state = await HostingerApiClient.instance.fetchState();
        if (state == null) return;
      }

      // Build local category lookup so MySQL products with null category_id keep their rich sub-category
      final localCategoryById = <String, String>{};
      for (final s in CustomerDemoData.stores) {
        for (final p in s.products) {
          if (p.category != null && p.category!.isNotEmpty) {
            localCategoryById[p.id] = p.category!;
          }
        }
      }

      // 1. Parse Products by vendorId
      final rawProducts = state['products'];
      final productsByVendor = <String, List<Product>>{};
      if (rawProducts is List) {
        for (final item in rawProducts) {
          final map = item is Map<String, dynamic>
              ? Map<String, dynamic>.from(item)
              : Map<String, dynamic>.from(item as Map);
          final prodId = map['id']?.toString() ?? '';
          if ((map['category'] == null || map['category'].toString().isEmpty) &&
              (map['category_id'] == null || map['category_id'].toString().isEmpty) &&
              localCategoryById.containsKey(prodId)) {
            map['category'] = localCategoryById[prodId];
          }
          final prod = Product.fromJson(map);
          productsByVendor.putIfAbsent(prod.vendorId, () => []).add(prod);
        }
      }

      // 2. Parse Stores and attach their live products
      final rawStores = state['stores'];
      if (rawStores is List && rawStores.isNotEmpty) {
        final updatedStores = <DemoStore>[];
        for (final item in rawStores) {
          final map = item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map);
          final storeId = map['id']?.toString() ?? '';
          final existingIdx = CustomerDemoData.stores.indexWhere((s) => s.id == storeId);
          final fallbackProducts = existingIdx != -1
              ? CustomerDemoData.stores[existingIdx].products
              : <Product>[];
          final storeProds = productsByVendor[storeId] ?? fallbackProducts;
          updatedStores.add(DemoStore.fromJson(map, storeProds));
        }

        if (updatedStores.isNotEmpty) {
          CustomerDemoData.stores
            ..clear()
            ..addAll(updatedStores);

          // Update active vendor store & products
          final vCtrl = VendorDemoController.instance;
          final activeIdx = CustomerDemoData.stores.indexWhere((s) => s.id == vCtrl.activeStoreId);
          if (activeIdx != -1) {
            final activeStore = CustomerDemoData.stores[activeIdx];
            vCtrl.store.name = activeStore.name;
            vCtrl.store.category = activeStore.categoryName;
            vCtrl.store.phone = activeStore.phone;
            vCtrl.store.address = activeStore.address;
            vCtrl.store.operatingHours = activeStore.operatingHours;
            vCtrl.store.ownerName = activeStore.ownerName;
            vCtrl.store.logoUrl = activeStore.logoUrl ?? activeStore.imageUrl;
            vCtrl.store.bannerUrl = activeStore.imageUrl;
            vCtrl.store.isOpen = activeStore.isOpen;
            vCtrl.products
              ..clear()
              ..addAll(activeStore.products);
          }
        }
      }

      // 3. Parse Live Rider Telemetry if present
      final rawTelemetry = state['rider_telemetry'];
      if (rawTelemetry is Map) {
        final rLat = (rawTelemetry['rider_lat'] as num?)?.toDouble();
        final rLng = (rawTelemetry['rider_lng'] as num?)?.toDouble();
        if (rLat != null && rLng != null) {
          RiderDemoController.instance.liveRiderLat = rLat;
          RiderDemoController.instance.liveRiderLng = rLng;
        }
      }

      // 4. Parse Live Orders
      final rawOrders = state['orders'];
      if (rawOrders is List && rawOrders.isNotEmpty) {
        final liveOrders = <MarketplaceOrder>[];
        for (final item in rawOrders) {
          final map = item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map);
          liveOrders.add(MarketplaceOrder.fromJson(map));
        }

        if (liveOrders.isNotEmpty) {
          VendorDemoController.instance.orders
            ..clear()
            ..addAll(liveOrders);

          CustomerDemoData.demoOrders
            ..clear()
            ..addAll(liveOrders);

          // Sync new orders to Rider assignments
          final rCtrl = RiderDemoController.instance;
          for (final ord in liveOrders) {
            if (ord.riderLat != null && ord.riderLng != null) {
              rCtrl.liveRiderLat = ord.riderLat!;
              rCtrl.liveRiderLng = ord.riderLng!;
            }
            final exists = rCtrl.assignments.any((a) => a.orderId == ord.id);
            if (!exists &&
                (ord.status == OrderStatus.placed ||
                    ord.status == OrderStatus.accepted ||
                    ord.status == OrderStatus.preparing ||
                    ord.status == OrderStatus.readyForPickup ||
                    ord.status == OrderStatus.outForDelivery)) {
              final storeObj = CustomerDemoData.stores.firstWhere(
                (s) => s.id == ord.vendorId,
                orElse: () => CustomerDemoData.stores.first,
              );
              rCtrl.assignments.insert(
                0,
                RiderDeliveryAssignment(
                  id: 'DEL-${ord.orderNumber ?? ord.id}',
                  orderId: ord.id,
                  orderNumber: ord.orderNumber ?? 1000,
                  storeName: storeObj.name,
                  pickupAddress: storeObj.address,
                  customerArea: 'Batkhela Delivery Zone',
                  customerAddress: ord.deliveryAddress,
                  customerLat: ord.deliveryLat,
                  customerLng: ord.deliveryLng,
                  customerNotes: ord.customerNotes,
                  itemNames: ord.items.isNotEmpty
                      ? ord.items.map((i) => '${i.quantity}x ${i.productName}').toList()
                      : ['Marketplace Order #${ord.orderNumber ?? ord.id}'],
                  cashToCollect: ord.totalAmount,
                  deliveryFeeEarnings: ord.deliveryFee > 0 ? ord.deliveryFee : 100.0,
                  distanceKm: 2.2,
                  estimatedMinutes: 10,
                  stage: ord.status == OrderStatus.outForDelivery
                      ? DeliveryStage.onTheWay
                      : DeliveryStage.offered,
                  createdAt: ord.createdAt,
                ),
              );
            }
          }
          rCtrl.notifyListeners();
        }
      }

      VendorDemoController.instance.notifyListeners();
      notifyListeners();
    } catch (e) {
      debugPrint('LiveSyncController.syncNow error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
