import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order.dart';
import '../order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _client;

  SupabaseOrderRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<MarketplaceOrder?> getOrderById(String orderId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();

    if (response == null) return null;
    final itemsJson = (response['order_items'] as List?) ?? [];
    final items = itemsJson.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
    return MarketplaceOrder.fromJson(response, items: items);
  }

  @override
  Future<MarketplaceOrder> placeOrder(MarketplaceOrder order) async {
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

  @override
  Future<MarketplaceOrder> updateStatus(
    String orderId,
    OrderStatus status, {
    String? notes,
  }) async {
    final response = await _client
        .from('orders')
        .update({
          'status': status.toDbString(),
          'customer_notes': ?notes,
        })
        .eq('id', orderId)
        .select('*, order_items(*)')
        .single();

    final itemsJson = (response['order_items'] as List?) ?? [];
    final items = itemsJson.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
    return MarketplaceOrder.fromJson(response, items: items);
  }

  @override
  Future<List<MarketplaceOrder>> getOrdersForCustomer(String customerId) async {
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
  Future<List<MarketplaceOrder>> getOrdersForVendor(String vendorId, {OrderStatus? status}) async {
    var query = _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('vendor_id', vendorId);

    if (status != null) {
      query = query.eq('status', status.toDbString());
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) {
      final itemsJson = (json['order_items'] as List?) ?? [];
      final items = itemsJson.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
      return MarketplaceOrder.fromJson(json as Map<String, dynamic>, items: items);
    }).toList();
  }

  @override
  Future<List<MarketplaceOrder>> getAllOrders({OrderStatus? status}) async {
    var query = _client.from('orders').select('*, order_items(*)');

    if (status != null) {
      query = query.eq('status', status.toDbString());
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) {
      final itemsJson = (json['order_items'] as List?) ?? [];
      final items = itemsJson.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
      return MarketplaceOrder.fromJson(json as Map<String, dynamic>, items: items);
    }).toList();
  }
}
