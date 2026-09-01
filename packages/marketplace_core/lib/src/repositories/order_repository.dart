import 'dart:async';
import '../models/order.dart';

abstract class OrderRepository {
  Future<MarketplaceOrder?> getOrderById(String orderId);
  Future<MarketplaceOrder> placeOrder(MarketplaceOrder order);
  Future<MarketplaceOrder> updateStatus(String orderId, OrderStatus status, {String? notes});
  Future<List<MarketplaceOrder>> getOrdersForCustomer(String customerId);
  Future<List<MarketplaceOrder>> getOrdersForVendor(String vendorId, {OrderStatus? status});
  Future<List<MarketplaceOrder>> getAllOrders({OrderStatus? status});

  // Realtime Streams (Phase 7E)
  Stream<MarketplaceOrder?> streamOrder(String orderId);
  Stream<List<MarketplaceOrder>> streamOrdersForCustomer(String customerId);
  Stream<List<MarketplaceOrder>> streamOrdersForVendor(String vendorId, {OrderStatus? status});
}
