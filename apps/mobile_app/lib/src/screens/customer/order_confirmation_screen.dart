import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/customer_demo_data.dart';
import '../../data/rider_demo_data.dart';
import '../../services/live_sync_controller.dart';
import '../../widgets/route_navigation_preview.dart';
import 'customer_home_screen.dart';

/// Soft, Clean Order Confirmation & Live Tracking Screen displayed right after order placement
class OrderConfirmationScreen extends StatelessWidget {
  final MarketplaceOrder order;

  static const Color _bgCream = Color(0xFFFAF6F0);
  static const Color _brandRed = Color(0xFFC8102E);
  static const Color _brandRedDark = Color(0xFF9E0B22);
  static const Color _textDark = Color(0xFF1E1915);
  static const Color _textMuted = Color(0xFF6E655F);
  static const Color _softBorder = Color(0xFFEDE6DC);

  const OrderConfirmationScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LiveSyncController.instance,
      builder: (context, _) {
        final liveOrder = CustomerDemoData.demoOrders.firstWhere(
          (o) => o.id == order.id,
          orElse: () => order,
        );
        final rLat = liveOrder.riderLat ?? RiderDemoController.instance.liveRiderLat;
        final rLng = liveOrder.riderLng ?? RiderDemoController.instance.liveRiderLng;
        final isSelfDelivery = liveOrder.deliveryAssignmentType == 'vendor_self';

        return Scaffold(
          backgroundColor: _bgCream,
          appBar: AppBar(
            backgroundColor: _bgCream,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Order #${liveOrder.orderNumber ?? liveOrder.id.substring(liveOrder.id.length - 4)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _textDark,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: _textDark),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil<void>(
                      context,
                      MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                children: [
                  // 1. Soft Confirmation Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _softBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 42,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Order Confirmed!',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            liveOrder.status.displayName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _brandRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (liveOrder.assignedRiderName != null &&
                            liveOrder.assignedRiderName!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            isSelfDelivery
                                ? '🏪 ${liveOrder.assignedRiderName}'
                                : '🛵 ${liveOrder.assignedRiderName}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Your order has been sent to the shop and live GPS tracking is active below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: _textMuted, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Clean Live Interactive Map
                  RouteNavigationPreview(
                    originTitle: 'Merchant Shop',
                    originAddress: 'Main Bazaar, Batkhela',
                    destinationTitle: 'Delivery Pin',
                    destinationAddress: liveOrder.deliveryAddress,
                    distanceKm: 2.1,
                    estimatedMinutes: 12,
                    originLat: 34.6175,
                    originLng: 71.9712,
                    destinationLat: liveOrder.deliveryLat ?? 34.6186,
                    destinationLng: liveOrder.deliveryLng ?? 71.9723,
                    riderLat: rLat,
                    riderLng: rLng,
                    isOutForDelivery: liveOrder.status == OrderStatus.outForDelivery,
                  ),
                  const SizedBox(height: 16),

                  // 3. Soft Receipt Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _softBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: _softBorder),
                        ),
                        ...liveOrder.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.productName}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: _softBorder),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'Rs. ${liveOrder.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _brandRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Back to Home Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_brandRed, _brandRedDark]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil<void>(
                            context,
                            MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home_rounded, size: 19),
                        label: const Text(
                          'Back to Marketplace Home',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
