import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category.dart';
import '../category_repository.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  final SupabaseClient _client;

  SupabaseCategoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<MarketplaceCategory>> getActiveCategories() async {
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
  Stream<List<MarketplaceCategory>> streamActiveCategories() {
    return _client
        .from('marketplace_categories')
        .stream(primaryKey: ['id'])
        .order('display_order', ascending: true)
        .map((data) => data
            .map((json) => MarketplaceCategory.fromJson(json))
            .where((c) => c.isActive)
            .toList());
  }

  @override
  Future<List<MarketplaceCategory>> getAllCategories() async {
    final response = await _client
        .from('marketplace_categories')
        .select()
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => MarketplaceCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MarketplaceCategory> toggleCategoryActive(String categoryId, bool isActive) async {
    final response = await _client
        .from('marketplace_categories')
        .update({'is_active': isActive})
        .eq('id', categoryId)
        .select()
        .single();

    return MarketplaceCategory.fromJson(response);
  }

  @override
  Future<MarketplaceCategory> saveCategory(MarketplaceCategory category) async {
    final response = await _client
        .from('marketplace_categories')
        .upsert(category.toJson())
        .select()
        .single();

    return MarketplaceCategory.fromJson(response);
  }
}
