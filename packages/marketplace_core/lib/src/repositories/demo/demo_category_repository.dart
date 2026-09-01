import '../../models/category.dart';
import '../category_repository.dart';

class DemoCategoryRepository implements CategoryRepository {
  final List<MarketplaceCategory> _categories = [
    const MarketplaceCategory(
      id: 'cat-1',
      slug: 'food-dining',
      name: 'Food & Dining',
      nameUrdu: 'کھانے پینے کی اشیاء',
      icon: 'restaurant',
      displayOrder: 1,
      isActive: true,
    ),
    const MarketplaceCategory(
      id: 'cat-2',
      slug: 'grocery-essentials',
      name: 'Grocery & Essentials',
      nameUrdu: 'کریانہ اور ضروریات',
      icon: 'local_grocery_store',
      displayOrder: 2,
      isActive: true,
    ),
    const MarketplaceCategory(
      id: 'cat-3',
      slug: 'fresh-fruits-vegetables',
      name: 'Fruits & Vegetables',
      nameUrdu: 'تازہ پھل اور سبزیاں',
      icon: 'eco',
      displayOrder: 3,
      isActive: true,
    ),
    const MarketplaceCategory(
      id: 'cat-4',
      slug: 'pharmacy-healthcare',
      name: 'Pharmacy & Health',
      nameUrdu: 'دواخانہ اور ادویات',
      icon: 'local_pharmacy',
      displayOrder: 4,
      isActive: true,
    ),
    const MarketplaceCategory(
      id: 'cat-5',
      slug: 'electronics-mobiles',
      name: 'Electronics & Mobiles',
      nameUrdu: 'الیکٹرانکس اور موبائلز',
      icon: 'devices',
      displayOrder: 5,
      isActive: true,
    ),
    const MarketplaceCategory(
      id: 'cat-6',
      slug: 'fashion-clothing',
      name: 'Fashion & Apparel',
      nameUrdu: 'کپڑے اور ملبوسات',
      icon: 'checkroom',
      displayOrder: 6,
      isActive: true,
    ),
  ];

  @override
  Future<List<MarketplaceCategory>> getActiveCategories() async {
    return _categories.where((c) => c.isActive).toList();
  }

  @override
  Future<List<MarketplaceCategory>> getAllCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<MarketplaceCategory> toggleCategoryActive(String categoryId, bool isActive) async {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      final updated = _categories[index].copyWith(isActive: isActive);
      _categories[index] = updated;
      return updated;
    }
    throw Exception('Category not found');
  }

  @override
  Future<MarketplaceCategory> saveCategory(MarketplaceCategory category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      return category;
    } else {
      _categories.add(category);
      return category;
    }
  }
}
