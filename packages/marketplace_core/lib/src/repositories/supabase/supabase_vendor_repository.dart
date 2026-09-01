import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/vendor.dart';
import '../../models/order.dart';
import '../vendor_repository.dart';

class SupabaseVendorRepository implements VendorRepository {
  final SupabaseClient _client;

  SupabaseVendorRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Vendor?> getVendorProfile(String vendorId) async {
    final response = await _client
        .from('vendors')
        .select()
        .eq('id', vendorId)
        .maybeSingle();

    if (response == null) return null;
    return Vendor.fromJson(response);
  }

  @override
  Future<Vendor> updateStoreStatus(String vendorId, {required bool isOpen}) async {
    final response = await _client
        .from('vendors')
        .update({'is_open': isOpen})
        .eq('id', vendorId)
        .select()
        .single();

    return Vendor.fromJson(response);
  }

  @override
  Future<List<MarketplaceOrder>> getVendorOrders(String vendorId, {OrderStatus? status}) async {
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
  Future<MarketplaceOrder> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? notes,
  }) async {
    final response = await _client
        .from('orders')
        .update({
          'status': newStatus.toDbString(),
          'customer_notes': ?notes,
        })
        .eq('id', orderId)
        .select('*, order_items(*)')
        .single();

    final itemsJson = (response['order_items'] as List?) ?? [];
    final items = itemsJson.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();
    return MarketplaceOrder.fromJson(response, items: items);
  }
}
