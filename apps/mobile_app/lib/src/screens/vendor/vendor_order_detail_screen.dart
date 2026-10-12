import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';

class VendorOrderDetailScreen extends StatelessWidget {
  final MarketplaceOrder order;

  const VendorOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VendorDemoController.instance,
      builder: (context, _) {
        // Fetch current live order from controller if updated
        final liveOrder = VendorDemoController.instance.orders.firstWhere(
          (o) => o.id == order.id,
          orElse: () => order,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title: Text(
              'Order #${liveOrder.orderNumber ?? liveOrder.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: MarketplaceStatusBadge.fromOrderStatus(liveOrder.status),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Delivery & Customer Card
              _buildCustomerCard(context, liveOrder),
              const SizedBox(height: 16),

              // Items Ordered
              _buildItemsCard(context, liveOrder),
              const SizedBox(height: 16),

              // Order Summary / Payment
              _buildPaymentSummaryCard(context, liveOrder),
              const SizedBox(height: 16),

              // Delivery Assignment & Self-Delivery Control Card
              _buildDeliveryAssignmentCard(context, liveOrder),
              const SizedBox(height: 16),

              // Status Timeline / Instructions
              _buildTimelineCard(context, liveOrder),
              const SizedBox(height: 100),
            ],
          ),
          bottomSheet: _buildBottomActionBar(context, liveOrder),
        );
      },
    );
  }

  Widget _buildCustomerCard(BuildContext context, MarketplaceOrder liveOrder) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.softCyan.withAlpha(50),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer ${liveOrder.customerId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Batkhela Marketplace Customer',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling customer via marketplace proxy...')),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: AppColors.coral),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        liveOrder.deliveryAddress,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (liveOrder.customerNotes != null && liveOrder.customerNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.coral.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.coral.withAlpha(40)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 18, color: AppColors.coral),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Special Note: ${liveOrder.customerNotes}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, MarketplaceOrder liveOrder) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordered Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (liveOrder.items.isEmpty)
              const Text('Standard catalog order')
            else
              ...liveOrder.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        'PKR ${item.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(BuildContext context, MarketplaceOrder liveOrder) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment & Bill Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Items Subtotal', 'PKR ${liveOrder.subtotal.toStringAsFixed(0)}'),
            const SizedBox(height: 6),
            _buildPriceRow('Delivery Fee', 'PKR ${liveOrder.deliveryFee.toStringAsFixed(0)}'),
            const SizedBox(height: 6),
            _buildPriceRow('Platform Fee', 'PKR ${liveOrder.platformFee.toStringAsFixed(0)}'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Collectable',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'PKR ${liveOrder.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, MarketplaceOrder liveOrder) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTimelineStep(
              title: 'Order Placed',
              subtitle: 'Customer sent order via Batkhela Marketplace',
              isCompleted: true,
            ),
            _buildTimelineStep(
              title: 'Order Accepted & Kitchen Assigned',
              subtitle: 'Vendor confirmed kitchen slot',
              isCompleted: liveOrder.status != OrderStatus.placed && liveOrder.status != OrderStatus.cancelled,
            ),
            _buildTimelineStep(
              title: 'Food Preparation',
              subtitle: 'Order is being cooked/packed in store',
              isCompleted: liveOrder.status == OrderStatus.preparing ||
                  liveOrder.status == OrderStatus.readyForPickup ||
                  liveOrder.status == OrderStatus.outForDelivery ||
                  liveOrder.status == OrderStatus.delivered,
            ),
            _buildTimelineStep(
              title: 'Ready for Rider Pickup',
              subtitle: 'Packed with receipt & assigned to Batkhela Rider network',
              isCompleted: liveOrder.status == OrderStatus.readyForPickup ||
                  liveOrder.status == OrderStatus.outForDelivery ||
                  liveOrder.status == OrderStatus.delivered,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildDeliveryAssignmentCard(BuildContext context, MarketplaceOrder liveOrder) {
    final ctrl = VendorDemoController.instance;
    final isVendorSelf = liveOrder.deliveryAssignmentType == 'vendor_self';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFC8102E).withAlpha(45)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8102E).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.two_wheeler_rounded, color: Color(0xFFC8102E), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Assignment (Self or Rider)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Jab order ready ho to khud deliver karein ya Rider ko assign karein',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (liveOrder.assignedRiderName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isVendorSelf ? const Color(0xFFFEF3C7) : AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isVendorSelf ? const Color(0xFFF59E0B) : AppColors.primary.withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVendorSelf ? Icons.storefront_rounded : Icons.two_wheeler_rounded,
                      color: isVendorSelf ? const Color(0xFFB45309) : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isVendorSelf
                            ? 'Vendor Self-Delivery Active: ${liveOrder.assignedRiderName}'
                            : 'Assigned Rider: ${liveOrder.assignedRiderName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: isVendorSelf ? const Color(0xFFB45309) : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8102E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await ctrl.assignOrderToVendorSelf(liveOrder.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFC8102E),
                          content: Text(
                            'Order #${liveOrder.orderNumber ?? liveOrder.id} assigned to ${ctrl.store.name} (Self-Delivery)! Live GPS ON.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.storefront_rounded, size: 17),
                    label: const Text(
                      'Khud Le Jaye (Self)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final firstRider = ctrl.riderApplications.first;
                      ctrl.assignOrderToRider(
                        liveOrder.id,
                        riderId: firstRider.id,
                        riderName: firstRider.name,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryDark,
                          content: Text('Order assigned to Rider ${firstRider.name}!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.two_wheeler_rounded, size: 17),
                    label: const Text(
                      'Assign Rider',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomActionBar(BuildContext context, MarketplaceOrder liveOrder) {
    if (liveOrder.status == OrderStatus.placed) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    VendorDemoController.instance.rejectOrder(liveOrder.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order rejected.')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reject Order'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8102E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    VendorDemoController.instance.acceptOrder(liveOrder.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Accepted!')),
                    );
                  },
                  child: const Text('Accept Order', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (liveOrder.status == OrderStatus.accepted) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                VendorDemoController.instance.startPreparing(liveOrder.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order marked as Preparing!')),
                );
              },
              icon: const Icon(Icons.soup_kitchen_outlined),
              label: const Text('Start Food Preparation', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );
    } else if (liveOrder.status == OrderStatus.preparing) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    VendorDemoController.instance.markReadyForPickup(liveOrder.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order marked Ready!')),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark Ready for Rider Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8102E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await VendorDemoController.instance.assignOrderToVendorSelf(liveOrder.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFFC8102E),
                        content: Text('Assigned to Vendor Self-Delivery! Live GPS ON.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.storefront_rounded, size: 18),
                  label: const Text('Khud Deliver (Self)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (liveOrder.status == OrderStatus.readyForPickup) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8102E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await VendorDemoController.instance.assignOrderToVendorSelf(liveOrder.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFFC8102E),
                    content: Text('Started Vendor Self-Delivery! Customer can track your live GPS.'),
                  ),
                );
              },
              icon: const Icon(Icons.two_wheeler_rounded),
              label: const Text('Khud Le Jayein (Start Vendor Self-Delivery)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );
    } else if (liveOrder.status == OrderStatus.outForDelivery) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC8102E),
                    side: const BorderSide(color: Color(0xFFC8102E)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await VendorDemoController.instance.broadcastVendorSelfDeliveryGps(liveOrder.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Live GPS sent to Customer map!')),
                    );
                  },
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Update My GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    VendorDemoController.instance.markOrderDeliveredByVendor(liveOrder.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text('Order Marked as Delivered!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark Delivered', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return null;
  }
}
