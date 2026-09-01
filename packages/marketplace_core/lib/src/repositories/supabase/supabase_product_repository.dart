import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import '../product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient? _customClient;

  SupabaseProductRepository({SupabaseClient? client}) : _customClient = client;

  SupabaseClient get _client => _customClient ?? Supabase.instance.client;

  @override
  Future<Product?> getProductById(String productId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .maybeSingle();

    if (response == null) return null;
    return Product.fromJson(response);
  }

  @override
  Future<List<Product>> getProductsByVendor(String vendorId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('vendor_id', vendorId)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> toggleProductAvailability(String productId, bool isAvailable) async {
    final response = await _client
        .from('products')
        .update({'is_available': isAvailable})
        .eq('id', productId)
        .select()
        .single();

    return Product.fromJson(response);
  }

  @override
  Future<Product> saveProduct(Product product) async {
    final response = await _client
        .from('products')
        .upsert(product.toJson())
        .select()
        .single();

    return Product.fromJson(response);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }
}
