import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/delivery.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String publishableKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: publishableKey,
    );
  }

  // Current Auth State
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Fetch User Profile
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Stream of Orders for a specific vendor
  Stream<List<MarketplaceOrder>> streamVendorOrders(String vendorId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => MarketplaceOrder.fromJson(json)).toList());
  }

  /// Stream of Orders for a customer
  Stream<List<MarketplaceOrder>> streamCustomerOrders(String customerId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => MarketplaceOrder.fromJson(json)).toList());
  }

  /// Stream of active delivery tasks for a rider
  Stream<List<DeliveryTask>> streamRiderDeliveries(String riderId) {
    return client
        .from('deliveries')
        .stream(primaryKey: ['id'])
        .eq('rider_id', riderId)
        .map((data) => data.map((json) => DeliveryTask.fromJson(json)).toList());
  }

  /// Fetch active verified vendors
  Future<List<Vendor>> fetchVendors() async {
    final response = await client
        .from('vendors')
        .select()
        .eq('is_verified', true)
        .eq('is_open', true)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Vendor.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch products for a vendor
  Future<List<Product>> fetchProducts(String vendorId) async {
    final response = await client
        .from('products')
        .select()
        .eq('vendor_id', vendorId)
        .eq('is_available', true)
        .order('name');

    return (response as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Update Rider Telemetry
  Future<void> updateRiderLocation({
    required String riderId,
    required double latitude,
    required double longitude,
    double heading = 0.0,
    bool isOnline = true,
  }) async {
    await client.from('rider_locations').upsert({
      'rider_id': riderId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'is_online': isOnline,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
