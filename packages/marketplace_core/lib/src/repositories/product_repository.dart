import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProductsByVendor(String vendorId);
  Future<Product?> getProductById(String productId);
  Future<Product> toggleProductAvailability(String productId, bool isAvailable);
  Future<Product> saveProduct(Product product);
  Future<void> deleteProduct(String productId);
}
