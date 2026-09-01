import 'dart:async';
import '../models/vendor.dart';
import '../models/order.dart';

abstract class VendorRepository {
  Future<Vendor?> getVendorProfile(String vendorId);
  Future<Vendor> updateStoreStatus(String vendorId, {required bool isOpen});
  Future<List<MarketplaceOrder>> getVendorOrders(String vendorId, {OrderStatus? status});
  Future<MarketplaceOrder> updateOrderStatus(String orderId, OrderStatus newStatus, {String? notes});

  // Realtime Streams (Phase 7E)
  Stream<List<MarketplaceOrder>> streamVendorOrders(String vendorId, {OrderStatus? status});
  Stream<Vendor?> streamVendorProfile(String vendorId);
}
