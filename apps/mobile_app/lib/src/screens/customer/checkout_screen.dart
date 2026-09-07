import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import 'order_confirmation_screen.dart';

/// Checkout and Order Placement Screen
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = CustomerDemoData.activeDeliveryAddress;
  String _paymentMethod = 'cash_on_delivery';
  final TextEditingController _notesController = TextEditingController();
  bool _isPlacingOrder = false;

  final List<String> _quickAddresses = const [
    'Main Bazaar, Near Clock Tower, Batkhela',
    'House 14, Street 2, Mohallah Zargarano, Batkhela',
    'Shop 5, Al-Khyber Plaza, Main GT Road, Batkhela',
    'Hospital Road, Near DHQ Hospital, Batkhela',
    'College Road, Near Degree College, Batkhela',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showAddressPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Select Delivery Address in Batkhela',
                  style: AppTypography.headline(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _quickAddresses.length,
                    separatorBuilder: (_, index) => const Divider(height: 8),
                    itemBuilder: (context, idx) {
                      final addr = _quickAddresses[idx];
                      final isSelected = addr == _selectedAddress;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        ),
                        title: Text(
                          addr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                          ),
                        ),
                        onTap: () {
                          setState(() => _selectedAddress = addr);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePlaceOrder() async {
    final cart = CartController.instance;
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Please add items before checkout.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final currentUserId = AuthService.instance.currentProfile?.id ?? 'usr_customer_1';
    final vendorId = cart.currentVendorId ?? 'store-1';
    final orderItems = cart.items.map((i) {
      return OrderItem(
        id: 'item-${DateTime.now().millisecondsSinceEpoch}-${i.product.id}',
        orderId: '',
        productId: i.product.id,
        productName: i.product.name,
        unitPrice: i.unitPrice,
        quantity: i.quantity,
        totalPrice: i.totalPrice,
      );
    }).toList();

    final orderNumber = 1000 + DateTime.now().millisecondsSinceEpoch % 9000;

    final newOrder = MarketplaceOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      customerId: currentUserId,
      vendorId: vendorId,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      platformFee: cart.platformFee,
      totalAmount: cart.totalAmount,
      status: OrderStatus.placed,
      paymentMethod: _paymentMethod,
      paymentStatus: _paymentMethod == 'cash_on_delivery' ? 'pending' : 'paid',
      deliveryAddress: _selectedAddress,
      deliveryLat: 34.6185,
      deliveryLng: 71.9723,
      customerNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      items: orderItems,
      createdAt: DateTime.now(),
    );

    try {
      await MarketplaceDataService.instance.orderRepo.placeOrder(newOrder);
    } catch (_) {
      // Ignored for resilient demo flow
    }

    // Trigger in-app notification
    try {
      await MarketplaceDataService.instance.notificationController.dispatchNotification(
        title: 'Order #$orderNumber Placed!',
        body: 'Your order from ${cart.currentVendorName ?? "Store"} has been confirmed and dispatched.',
        type: NotificationType.orderPlaced,
        orderId: newOrder.id,
        payload: {'order_id': newOrder.id},
      );
    } catch (_) {
      // Ignored
    }

    // Clear cart
    CartController.instance.clear();

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => OrderConfirmationScreen(order: newOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // 1. Delivery Address Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppElevation.softSubtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Delivery Location',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showAddressPicker(context),
                              child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedAddress,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Order Items Review
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppElevation.softSubtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cart.currentVendorName ?? 'Order Items',
                              style: AppTypography.headline(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${cart.totalItemCount} Items',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        ...cart.items.map((i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${i.quantity}x',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    i.product.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'PKR ${i.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Payment Method Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppElevation.softSubtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: () => setState(() => _paymentMethod = 'cash_on_delivery'),
                          borderRadius: AppRadius.roundedMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                Icon(
                                  _paymentMethod == 'cash_on_delivery'
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: _paymentMethod == 'cash_on_delivery'
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('💵 Cash on Delivery (COD)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                          SizedBox(width: 6),
                                          Text('(Recommended)', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Text('Pay with cash when rider arrives at your doorstep', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 12),
                        InkWell(
                          onTap: () => setState(() => _paymentMethod = 'jazzcash_easypaisa'),
                          borderRadius: AppRadius.roundedMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                Icon(
                                  _paymentMethod == 'jazzcash_easypaisa'
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: _paymentMethod == 'jazzcash_easypaisa'
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('📱 JazzCash / Easypaisa (Direct Demo)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      SizedBox(height: 2),
                                      Text('Instant mobile wallet transfer confirmation', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Delivery Instructions
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppElevation.softSubtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rider Delivery Instructions',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Ring bell, call when outside, leave at gate...',
                            hintStyle: TextStyle(fontSize: 12),
                            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 5. Bill Summary Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppElevation.softSubtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Items Subtotal', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text('PKR ${cart.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Fee (Batkhela)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text(
                              cart.deliveryFee == 0 ? 'FREE' : 'PKR ${cart.deliveryFee.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cart.deliveryFee == 0 ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Platform Fee', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text('PKR ${cart.platformFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              'PKR ${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // Bottom Place Order Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
                boxShadow: AppElevation.softCard,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
                    elevation: 3,
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Place Order (COD)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('PKR ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
