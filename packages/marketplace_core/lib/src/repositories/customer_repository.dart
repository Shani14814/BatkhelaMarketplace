import 'dart:async';
import '../models/category.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../models/customer_address.dart';
import '../models/order.dart';

abstract class CustomerRepository {
  Future<List<MarketplaceCategory>> getCategories();
  Future<List<Vendor>> getVendors({String? categoryId, String? searchQuery});
  Future<Vendor?> getVendorById(String vendorId);
  Future<List<Product>> getVendorProducts(String vendorId);
  Future<List<CustomerAddress>> getCustomerAddresses(String userId);
  Future<CustomerAddress> addCustomerAddress(CustomerAddress address);
  Future<void> setDefaultAddress(String userId, String addressId);
  Future<List<MarketplaceOrder>> getCustomerOrders(String customerId);
  Future<MarketplaceOrder> createOrder(MarketplaceOrder order);

  // Realtime Streams (Phase 7E)
  Stream<List<MarketplaceOrder>> streamCustomerOrders(String customerId);
}
