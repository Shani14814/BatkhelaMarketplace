import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<MarketplaceCategory>> getActiveCategories();
  Future<List<MarketplaceCategory>> getAllCategories();
  Future<MarketplaceCategory> toggleCategoryActive(String categoryId, bool isActive);
  Future<MarketplaceCategory> saveCategory(MarketplaceCategory category);
}
