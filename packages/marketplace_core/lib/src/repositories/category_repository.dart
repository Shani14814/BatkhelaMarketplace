import 'dart:async';
import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<MarketplaceCategory>> getActiveCategories();
  Future<List<MarketplaceCategory>> getAllCategories();
  Future<MarketplaceCategory> toggleCategoryActive(String categoryId, bool isActive);
  Future<MarketplaceCategory> saveCategory(MarketplaceCategory category);

  // Realtime Streams (Phase 7E)
  Stream<List<MarketplaceCategory>> streamActiveCategories();
}
