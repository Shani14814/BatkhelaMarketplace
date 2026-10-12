import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'checkout_screen.dart';

/// Soft, modern modal bottom sheet displaying the current active shopping cart items
class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  static const Color _bgCream = Color(0xFFFAF6F0);
  static const Color _brandRed = Color(0xFFC8102E);
  static const Color _brandRedDark = Color(0xFF9E0B22);
  static const Color _textDark = Color(0xFF1E1915);
  static const Color _textMuted = Color(0xFF6E655F);
  static const Color _softBorder = Color(0xFFEDE6DC);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CartSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.86,
      ),
      decoration: const BoxDecoration(
        color: _bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartController.instance.itemsNotifier,
          builder: (context, items, _) {
            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }
            return _buildCartContent(context, items);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 38, color: _brandRed),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Browse Batkhela restaurants, grocery stores & pharmacies to add items to your cart.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Explore Batkhela Marketplace',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, List<CartItem> items) {
    final cart = CartController.instance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Cart (${cart.totalItemCount})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                    ),
                  ),
                  if (cart.currentVendorName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Shop: ${cart.currentVendorName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _brandRed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
              TextButton.icon(
                onPressed: () => CartController.instance.clear(),
                icon: const Icon(Icons.delete_outline_rounded, size: 17, color: _brandRed),
                label: const Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _brandRed,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Items List
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _softBorder),
                ),
                child: Row(
                  children: [
                    MarketplaceProductImage(
                      imageUrl: item.product.imageUrl,
                      productName: item.product.name,
                      category: item.product.category,
                      width: 54,
                      height: 54,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: _textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Rs. ${item.unitPrice.toStringAsFixed(0)} each',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Soft Quantity Stepper
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: _bgCream,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _softBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => cart.updateQuantity(item.product.id, -1),
                            child: const Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.remove_rounded, size: 15, color: _textDark),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                                color: _textDark,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => cart.updateQuantity(item.product.id, 1),
                            child: const Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.add_rounded, size: 15, color: _brandRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: _brandRed,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Bill Summary Box
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _softBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(color: _textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Text('Rs. ${cart.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _textDark)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Fee', style: TextStyle(color: _textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Text(
                    cart.deliveryFee == 0 ? 'FREE' : 'Rs. ${cart.deliveryFee.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: cart.deliveryFee == 0 ? const Color(0xFF15803D) : _textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Platform Fee', style: TextStyle(color: _textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Text('Rs. ${cart.platformFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _textDark)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: _softBorder),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payable',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: _textDark),
                  ),
                  Text(
                    'Rs. ${cart.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: _brandRed),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Checkout Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_brandRed, _brandRedDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _brandRed.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Proceed to Checkout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Rs. ${cart.totalAmount.toStringAsFixed(0)} →',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
