import '../../models/product.dart';
import '../product_repository.dart';

class DemoProductRepository implements ProductRepository {
  final List<Product> _products = [
    Product(
      id: 'p-1',
      vendorId: 'store-1',
      categoryId: 'cat-1',
      category: 'Food & Dining',
      name: 'Special Shinwari Mutton Karahi (1 KG)',
      description: 'Fresh organic mutton cooked in its own natural fat with tomatoes, salt, and green chilies.',
      price: 2400.0,
      discountPrice: 2250.0,
      stockQuantity: 25,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      createdAt: DateTime(2026, 1, 1),
    ),
    Product(
      id: 'p-2',
      vendorId: 'store-1',
      categoryId: 'cat-1',
      category: 'Food & Dining',
      name: 'Peshawari Chapli Kabab (Plate)',
      description: 'Spiced minced beef patties shallow fried with tomato slices and crushed coriander.',
      price: 450.0,
      discountPrice: 400.0,
      stockQuantity: 40,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=800&q=80',
      createdAt: DateTime(2026, 1, 2),
    ),
    Product(
      id: 'p-3',
      vendorId: 'store-1',
      categoryId: 'cat-1',
      category: 'Food & Dining',
      name: 'Dum Pukht Special Rice',
      description: 'Slow-cooked meat and basmati rice with whole spices in an airtight handi.',
      price: 950.0,
      discountPrice: 850.0,
      stockQuantity: 15,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&q=80',
      createdAt: DateTime(2026, 1, 3),
    ),
  ];

  @override
  Future<List<Product>> getProductsByVendor(String vendorId) async {
    return _products.where((p) => p.vendorId == vendorId).toList();
  }

  @override
  Future<Product?> getProductById(String productId) async {
    final match = _products.where((p) => p.id == productId);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<Product> toggleProductAvailability(String productId, bool isAvailable) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final existing = _products[index];
      final updated = Product(
        id: existing.id,
        vendorId: existing.vendorId,
        categoryId: existing.categoryId,
        category: existing.category,
        name: existing.name,
        description: existing.description,
        price: existing.price,
        discountPrice: existing.discountPrice,
        stockQuantity: existing.stockQuantity,
        isAvailable: isAvailable,
        imageUrl: existing.imageUrl,
        createdAt: existing.createdAt,
      );
      _products[index] = updated;
      return updated;
    }
    throw Exception('Product not found');
  }

  @override
  Future<Product> saveProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      return product;
    } else {
      _products.add(product);
      return product;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
  }
}
