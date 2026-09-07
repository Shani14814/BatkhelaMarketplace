import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// Single item in the Customer's shopping cart
class CartItem {
  final Product product;
  int quantity;
  final String vendorId;
  final String vendorName;
  final String? specialInstructions;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.vendorId,
    required this.vendorName,
    this.specialInstructions,
  });

  double get unitPrice => product.effectivePrice;
  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? vendorId,
    String? vendorName,
    String? specialInstructions,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

/// Central Shopping Cart State Controller for Batkhela Marketplace
class CartController {
  static final CartController instance = CartController._internal();
  CartController._internal();

  /// Reactive notifier holding current items in cart
  final ValueNotifier<List<CartItem>> itemsNotifier = ValueNotifier<List<CartItem>>([]);

  List<CartItem> get items => List.unmodifiable(itemsNotifier.value);
  bool get isEmpty => itemsNotifier.value.isEmpty;
  bool get isNotEmpty => itemsNotifier.value.isNotEmpty;

  int get totalItemCount => itemsNotifier.value.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => itemsNotifier.value.fold(0.0, (sum, i) => sum + i.totalPrice);

  /// Free delivery above PKR 1500, otherwise PKR 50 standard local delivery fee
  double get deliveryFee => subtotal == 0 ? 0.0 : (subtotal >= 1500 ? 0.0 : 50.0);

  /// Fixed nominal Batkhela marketplace platform fee (PKR 20)
  double get platformFee => subtotal == 0 ? 0.0 : 20.0;

  double get totalAmount => subtotal == 0 ? 0.0 : subtotal + deliveryFee + platformFee;

  String? get currentVendorId => itemsNotifier.value.isEmpty ? null : itemsNotifier.value.first.vendorId;
  String? get currentVendorName => itemsNotifier.value.isEmpty ? null : itemsNotifier.value.first.vendorName;

  /// Add product to cart. Returns true if added, false if item from another vendor and prompt needed.
  bool addItem(
    Product product, {
    int quantity = 1,
    required String vendorId,
    required String vendorName,
    String? specialInstructions,
    bool clearIfDifferentVendor = false,
  }) {
    if (quantity <= 0) return false;

    var currentList = List<CartItem>.from(itemsNotifier.value);

    // If cart has items from another store
    if (currentList.isNotEmpty && currentList.first.vendorId != vendorId) {
      if (!clearIfDifferentVendor) {
        return false;
      }
      currentList.clear();
    }

    final existingIndex = currentList.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      currentList[existingIndex].quantity += quantity;
      if (specialInstructions != null && specialInstructions.isNotEmpty) {
        currentList[existingIndex] = currentList[existingIndex].copyWith(
          specialInstructions: specialInstructions,
        );
      }
    } else {
      currentList.add(
        CartItem(
          product: product,
          quantity: quantity,
          vendorId: vendorId,
          vendorName: vendorName,
          specialInstructions: specialInstructions,
        ),
      );
    }

    itemsNotifier.value = currentList;
    return true;
  }

  void updateQuantity(String productId, int delta) {
    var currentList = List<CartItem>.from(itemsNotifier.value);
    final index = currentList.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final newQty = currentList[index].quantity + delta;
      if (newQty <= 0) {
        currentList.removeAt(index);
      } else {
        currentList[index].quantity = newQty;
      }
      itemsNotifier.value = currentList;
    }
  }

  void removeItem(String productId) {
    var currentList = List<CartItem>.from(itemsNotifier.value);
    currentList.removeWhere((i) => i.product.id == productId);
    itemsNotifier.value = currentList;
  }

  void clear() {
    itemsNotifier.value = [];
  }
}
