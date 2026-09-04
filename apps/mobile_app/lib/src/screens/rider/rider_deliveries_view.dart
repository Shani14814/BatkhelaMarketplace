import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import 'rider_delivery_detail_screen.dart';

class RiderDeliveriesView extends StatelessWidget {
  const RiderDeliveriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final ctrl = RiderDemoController.instance;

        final offered = ctrl.offeredAssignments;
        final active = ctrl.assignments.where((a) =>
            a.stage == DeliveryStage.accepted ||
            a.stage == DeliveryStage.arrivedAtPickup ||
            a.stage == DeliveryStage.pickedUp ||
            a.stage == DeliveryStage.onTheWay).toList();
        final completed = ctrl.completedAssignments;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              title: const Text('Delivery Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
              bottom: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Job Offers'),
                  Tab(text: 'In-Progress'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildDeliveriesList(context, offered, tabType: 0),
                _buildDeliveriesList(context, active, tabType: 1),
                _buildDeliveriesList(context, completed, tabType: 2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeliveriesList(BuildContext context, List<RiderDeliveryAssignment> list, {int tabType = 0}) {
    final isOffersTab = tabType == 0;
    if (list.isEmpty) {
      IconData emptyIcon;
      Color iconColor;
      String title;
      String subtitle;

      if (tabType == 0) {
        emptyIcon = Icons.radar;
        iconColor = AppColors.coral;
        title = 'No Nearby Dispatch Broadcasts';
        subtitle = 'Stay online with GPS enabled. New delivery requests from Batkhela stores will appear here in real-time.';
      } else if (tabType == 1) {
        emptyIcon = Icons.two_wheeler_outlined;
        iconColor = AppColors.primary;
        title = 'No Active In-Flight Deliveries';
        subtitle = 'Check the Job Offers tab to accept available orders and start your route to the merchant.';
      } else {
        emptyIcon = Icons.task_alt_outlined;
        iconColor = AppColors.success;
        title = 'No Completed Trips Yet';
        subtitle = 'Completed delivery routes and accumulated payout earnings will be recorded here.';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(emptyIcon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final delivery = list[index];
        return _buildDeliveryCard(context, delivery, isOffersTab: isOffersTab);
      },
    );
  }

  Widget _buildDeliveryCard(BuildContext context, RiderDeliveryAssignment delivery, {bool isOffersTab = false}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOffersTab ? AppColors.coral.withAlpha(50) : AppColors.primary.withAlpha(20),
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RiderDeliveryDetailScreen(delivery: delivery),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${delivery.orderNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _badgeBgColor(delivery.stage),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      delivery.stage.displayName,
                      style: TextStyle(
                        color: _badgeTextColor(delivery.stage),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Store and destination
              Row(
                children: [
                  const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pickup: ${delivery.storeName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deliver to: ${delivery.customerArea}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Telemetry & Earnings Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.near_me_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${delivery.distanceKm} km • ~${delivery.estimatedMinutes} mins',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Text(
                    'Earn: PKR ${delivery.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // If offered, inline Accept / Decline buttons
              if (isOffersTab && delivery.stage == DeliveryStage.offered) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          RiderDemoController.instance.declineAssignment(delivery.id);
                        },
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          RiderDemoController.instance.acceptAssignment(delivery.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Delivery Accepted! Starting route.')),
                          );
                        },
                        child: const Text('Accept Job'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _badgeBgColor(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.offered:
        return AppColors.coral.withAlpha(20);
      case DeliveryStage.accepted:
      case DeliveryStage.arrivedAtPickup:
      case DeliveryStage.pickedUp:
      case DeliveryStage.onTheWay:
        return AppColors.primary.withAlpha(20);
      case DeliveryStage.delivered:
        return AppColors.success.withAlpha(20);
      case DeliveryStage.declined:
        return AppColors.error.withAlpha(20);
    }
  }

  Color _badgeTextColor(DeliveryStage stage) {
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
}
