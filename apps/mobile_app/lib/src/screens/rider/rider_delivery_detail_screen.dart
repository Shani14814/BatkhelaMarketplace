import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import '../../widgets/route_navigation_preview.dart';

class RiderDeliveryDetailScreen extends StatelessWidget {
  final RiderDeliveryAssignment delivery;

  const RiderDeliveryDetailScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final liveDelivery = RiderDemoController.instance.assignments.firstWhere(
          (d) => d.id == delivery.id,
          orElse: () => delivery,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title: Text(
              'Delivery #${liveDelivery.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _stageColor(liveDelivery.stage).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      liveDelivery.stage.displayName,
                      style: TextStyle(
                        color: _stageColor(liveDelivery.stage),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Route & Map Navigation Preview Card
              RouteNavigationPreview(
                originTitle: liveDelivery.storeName,
                originAddress: liveDelivery.pickupAddress,
                destinationTitle: liveDelivery.customerArea,
                destinationAddress: liveDelivery.customerAddress,
                distanceKm: liveDelivery.distanceKm,
                estimatedMinutes: liveDelivery.estimatedMinutes,
              ),
              const SizedBox(height: 16),

              // Cash Collection & Earnings Highlight
              _buildEarningsCard(context, liveDelivery),
              const SizedBox(height: 16),

              // Pickup Store Details Card
              _buildStorePickupCard(context, liveDelivery),
              const SizedBox(height: 16),

              // Customer Drop-off Card
              _buildCustomerDropoffCard(context, liveDelivery),
              const SizedBox(height: 16),

              // Package Item Checklist
              _buildItemChecklistCard(context, liveDelivery),
              const SizedBox(height: 80),
            ],
          ),
          bottomSheet: _buildContextualActionBar(context, liveDelivery),
        );
      },
    );
  }

  Widget _buildEarningsCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cash to Collect', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    'PKR ${liveDelivery.cashToCollect.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Cash on Delivery (Batkhela)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rider Earnings', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    'PKR ${liveDelivery.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Fee + Tip included', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorePickupCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Store',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        liveDelivery.storeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${liveDelivery.storeName}...')),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    liveDelivery.pickupAddress,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDropoffCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.coral.withAlpha(30)),
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
                    color: AppColors.coral.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_pin_circle_outlined, color: AppColors.coral, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Drop-off Destination',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        liveDelivery.customerArea,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.coral),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling customer via marketplace proxy...')),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    liveDelivery.customerAddress,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (liveDelivery.customerNotes != null && liveDelivery.customerNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.coral.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: AppColors.coral),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instructions: ${liveDelivery.customerNotes}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
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

  Widget _buildItemChecklistCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
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
              'Package Item Checklist',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verify package seal and items with store merchant before leaving.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Divider(height: 20),
            ...liveDelivery.itemNames.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_box_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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

  Widget? _buildContextualActionBar(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    if (liveDelivery.stage == DeliveryStage.delivered || liveDelivery.stage == DeliveryStage.declined) {
      return null;
    }

    if (liveDelivery.stage == DeliveryStage.offered) {
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
                    RiderDemoController.instance.declineAssignment(liveDelivery.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delivery offer declined.')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    RiderDemoController.instance.acceptAssignment(liveDelivery.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assignment Accepted! Head to store for pickup.')),
                    );
                  },
                  child: const Text('Accept Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _stageActionColor(liveDelivery.stage),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              RiderDemoController.instance.progressDeliveryStage(liveDelivery.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status updated: ${liveDelivery.stage.nextActionLabel}')),
              );
            },
            icon: Icon(_stageActionIcon(liveDelivery.stage)),
            label: Text(
              liveDelivery.stage.nextActionLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Color _stageColor(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.offered:
        return AppColors.coral;
      case DeliveryStage.accepted:
      case DeliveryStage.arrivedAtPickup:
      case DeliveryStage.pickedUp:
      case DeliveryStage.onTheWay:
        return AppColors.primary;
      case DeliveryStage.delivered:
        return AppColors.success;
      case DeliveryStage.declined:
        return AppColors.error;
    }
  }

  Color _stageActionColor(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.accepted:
        return AppColors.indigo;
      case DeliveryStage.arrivedAtPickup:
        return AppColors.primary;
      case DeliveryStage.pickedUp:
        return AppColors.indigo;
      case DeliveryStage.onTheWay:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _stageActionIcon(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.accepted:
        return Icons.navigation;
      case DeliveryStage.arrivedAtPickup:
        return Icons.shopping_bag_outlined;
      case DeliveryStage.pickedUp:
        return Icons.two_wheeler;
      case DeliveryStage.onTheWay:
        return Icons.check_circle_outline;
      default:
        return Icons.arrow_forward;
    }
  }
}
