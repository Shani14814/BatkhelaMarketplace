import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category.dart';
import '../../models/vendor.dart';
import '../../models/product.dart';
import '../../models/customer_address.dart';
import '../../models/order.dart';
import '../customer_repository.dart';

class SupabaseCustomerRepository implements CustomerRepository {
  final SupabaseClient _client;

  SupabaseCustomerRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<MarketplaceCategory>> getCategories() async {
    final response = await _client
        .from('marketplace_categories')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => MarketplaceCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Vendor>> getVendors({String? categoryId, String? searchQuery}) async {
    var query = _client
        .from('vendors')
        .select()
        .eq('is_verified', true);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('store_name', '%$searchQuery%');
    }

    final response = await query.order('store_name', ascending: true);

    return (response as List)
        .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Vendor?> getVendorById(String vendorId) async {
    final response = await _client
        .from('vendors')
        .select()
        .eq('id', vendorId)
        .maybeSingle();

    if (response == null) return null;
    return Vendor.fromJson(response);
  }

  @override
  Future<List<Product>> getVendorProducts(String vendorId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('vendor_id', vendorId)
        .eq('is_available', true)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CustomerAddress>> getCustomerAddresses(String userId) async {
    final response = await _client
        .from('customer_addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false);

    return (response as List)
        .map((json) => CustomerAddress.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CustomerAddress> addCustomerAddress(CustomerAddress address) async {
    final response = await _client
        .from('customer_addresses')
        .insert(address.toJson())
        .select()
        .single();

    return CustomerAddress.fromJson(response);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    // Unset all default
    await _client
        .from('customer_addresses')
        .update({'is_default': false})
        .eq('user_id', userId);

    // Set specific default
    await _client
        .from('customer_addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }

  @override
  Future<List<MarketplaceOrder>> getCustomerOrders(String customerId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final itemsJson = (json['order_items'] as List?) ?? [];
      final items = itemsJson.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
      return MarketplaceOrder.fromJson(json as Map<String, dynamic>, items: items);
    }).toList();
  }

  @override
  Future<MarketplaceOrder> createOrder(MarketplaceOrder order) async {
    // Trusted totals calculation
    double subtotal = 0.0;
    for (final item in order.items) {
      subtotal += item.totalPrice;
    }
    final trustedTotal = subtotal + order.deliveryFee + order.platformFee;

    final orderPayload = order.toJson();
    orderPayload['subtotal'] = subtotal > 0 ? subtotal : order.subtotal;
    orderPayload['total_amount'] = trustedTotal > 0 ? trustedTotal : order.totalAmount;

    final response = await _client
        .from('orders')
        .insert(orderPayload)
        .select()
        .single();

    final createdOrder = MarketplaceOrder.fromJson(response);

    if (order.items.isNotEmpty) {
      final itemsPayload = order.items.map((i) {
        final j = i.toJson();
        j['order_id'] = createdOrder.id;
        return j;
      }).toList();

      await _client.from('order_items').insert(itemsPayload);
    }

    return createdOrder;
  }
}
