import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  group('CartController Unit Tests', () {
    late CartController cart;

    final testProduct1 = Product(
      id: 'prod_1',
      vendorId: 'vendor_a',
      name: 'Shinwari Mutton Karahi',
      category: 'Food & Dining',
      price: 1000.0,
      discountPrice: 900.0,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947',
      createdAt: DateTime.now(),
    );

    final testProduct2 = Product(
      id: 'prod_2',
      vendorId: 'vendor_a',
      name: 'Fresh Roghani Naan',
      category: 'Food & Dining',
      price: 50.0,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc',
      createdAt: DateTime.now(),
    );

    final testProductOtherVendor = Product(
      id: 'prod_3',
      vendorId: 'vendor_b',
      name: 'Panadol Extra Tablets',
      category: 'Pharmacy',
      price: 200.0,
      isAvailable: true,
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
      createdAt: DateTime.now(),
    );

    setUp(() {
      cart = CartController.instance;
      cart.clear();
    });

    test('Initial cart state is empty with 0 totals', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.isNotEmpty, isFalse);
      expect(cart.totalItemCount, 0);
      expect(cart.subtotal, 0.0);
      expect(cart.deliveryFee, 0.0);
      expect(cart.totalAmount, 0.0);
      expect(cart.currentVendorId, isNull);
    });

    test('Adding single item sets vendor and calculates discounted price correctly', () {
      final success = cart.addItem(
        testProduct1,
        vendorId: 'vendor_a',
        vendorName: 'Khyber Shinwari',
        quantity: 1,
      );

      expect(success, isTrue);
      expect(cart.isEmpty, isFalse);
      expect(cart.totalItemCount, 1);
      expect(cart.currentVendorId, 'vendor_a');
      expect(cart.currentVendorName, 'Khyber Shinwari');
      expect(cart.subtotal, 900.0);
      expect(cart.deliveryFee, 50.0);
      expect(cart.platformFee, 20.0);
      expect(cart.totalAmount, 970.0);
    });

    test('Adding quantity above threshold grants free delivery', () {
      cart.addItem(
        testProduct1,
        vendorId: 'vendor_a',
        vendorName: 'Khyber Shinwari',
        quantity: 2,
      );

      expect(cart.subtotal, 1800.0);
      expect(cart.deliveryFee, 0.0);
      expect(cart.platformFee, 20.0);
      expect(cart.totalAmount, 1820.0);
    });

    test('Updating quantity and removing item when quantity reaches 0', () {
      cart.addItem(
        testProduct1,
        vendorId: 'vendor_a',
        vendorName: 'Khyber Shinwari',
        quantity: 1,
      );
      cart.addItem(
        testProduct2,
        vendorId: 'vendor_a',
        vendorName: 'Khyber Shinwari',
        quantity: 2,
      );

      expect(cart.totalItemCount, 3);
      expect(cart.items.length, 2);

      // Increase quantity by delta +1 (2 -> 3)
      cart.updateQuantity('prod_2', 1);
      expect(cart.totalItemCount, 4);

      // Decrease by delta -3 (3 -> 0), which removes it
      cart.updateQuantity('prod_2', -3);
      expect(cart.totalItemCount, 1);
      expect(cart.items.length, 1);
      expect(cart.items.first.product.id, 'prod_1');

      cart.removeItem('prod_1');
      expect(cart.isEmpty, isTrue);
      expect(cart.currentVendorId, isNull);
    });

    test('Adding product from different vendor is prevented unless clearIfDifferentVendor is true', () {
      cart.addItem(
        testProduct1,
        vendorId: 'vendor_a',
        vendorName: 'Khyber Shinwari',
        quantity: 1,
      );

      final added = cart.addItem(
        testProductOtherVendor,
        vendorId: 'vendor_b',
        vendorName: 'Batkhela Pharmacy',
        quantity: 1,
        clearIfDifferentVendor: false,
      );

      expect(added, isFalse);
      expect(cart.currentVendorId, 'vendor_a');
      expect(cart.items.length, 1);

      final forcedAdd = cart.addItem(
        testProductOtherVendor,
        vendorId: 'vendor_b',
        vendorName: 'Batkhela Pharmacy',
        quantity: 2,
        clearIfDifferentVendor: true,
      );

      expect(forcedAdd, isTrue);
      expect(cart.currentVendorId, 'vendor_b');
      expect(cart.currentVendorName, 'Batkhela Pharmacy');
      expect(cart.items.length, 1);
      expect(cart.items.first.product.id, 'prod_3');
      expect(cart.items.first.quantity, 2);
    });
  });
}
