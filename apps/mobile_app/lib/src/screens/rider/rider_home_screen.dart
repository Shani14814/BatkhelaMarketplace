import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import 'rider_deliveries_view.dart';
import 'rider_delivery_detail_screen.dart';
import 'rider_earnings_view.dart';
import 'rider_profile_view.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final ctrl = RiderDemoController.instance;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeRadarTab(context, ctrl),
              const RiderDeliveriesView(),
              const RiderEarningsView(),
              const RiderProfileView(),
            ],
          ),
          bottomNavigationBar: MarketplaceBottomNav(
            currentIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              MarketplaceNavDestination(
                icon: Icons.radar_outlined,
                activeIcon: Icons.radar,
                label: 'Radar',
              ),
              MarketplaceNavDestination(
                icon: Icons.two_wheeler_outlined,
                activeIcon: Icons.two_wheeler,
                label: 'Deliveries',
              ),
              MarketplaceNavDestination(
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments,
                label: 'Earnings',
              ),
              MarketplaceNavDestination(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 0: RIDER RADAR / HOME
  // ----------------------------------------------------
  Widget _buildHomeRadarTab(BuildContext context, RiderDemoController ctrl) {
    final activeDelivery = ctrl.activeDelivery;
    final offeredCount = ctrl.offeredAssignments.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rider Delivery Radar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ctrl.isOnline ? AppColors.primary : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  ctrl.isOnline ? 'ONLINE • Broadcasting Telemetry' : 'OFFLINE • Paused',
                  style: TextStyle(
                    fontSize: 11,
                    color: ctrl.isOnline ? AppColors.primary : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Switch(
            value: ctrl.isOnline,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              ctrl.toggleOnlineStatus(val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? 'Rider radar is ONLINE' : 'Rider radar is OFFLINE'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Live GPS Telemetry Status Banner
          _buildGpsTelemetryBanner(context, ctrl),
          const SizedBox(height: 16),

          // Operational KPI Metrics (2 Cards)
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: "Today's Earnings",
                  value: 'PKR ${ctrl.todayEarnings.toStringAsFixed(0)}',
                  trend: '+24% vs yesterday',
                  isPositive: true,
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Today Completed',
                  value: '${ctrl.todayCompletedCount} Trips',
                  trend: '${ctrl.profile.rating} ★ Rating',
                  isPositive: true,
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // New Offers Alert Banner
          if (offeredCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.coral.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.coral.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notification_important, color: AppColors.coral),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$offeredCount New Delivery Assignment Offered',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral, fontSize: 13),
                        ),
                        const Text(
                          'Review and accept to start pickup immediately.',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text('View Offer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Active Delivery Hero Card
          const Text(
            'Current Assigned Delivery',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          if (activeDelivery != null)
            _buildActiveDeliveryHeroCard(context, activeDelivery)
          else
            _buildNoActiveDeliveryCard(context),

          const SizedBox(height: 20),

          // Quick Operational Actions Grid
          const Text(
            'Quick Operations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VendorQuickActionButton(
                  label: 'Deliveries Hub',
                  icon: Icons.two_wheeler,
                  badgeCount: offeredCount > 0 ? offeredCount : null,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VendorQuickActionButton(
                  label: 'My Earnings',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpsTelemetryBanner(BuildContext context, RiderDemoController ctrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ctrl.isOnline ? AppColors.primary.withAlpha(15) : AppColors.error.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ctrl.isOnline ? AppColors.primary.withAlpha(40) : AppColors.error.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ctrl.isOnline ? Icons.gps_fixed : Icons.gps_off,
            color: ctrl.isOnline ? AppColors.primary : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.isOnline ? 'Batkhela GPS Node Broadcasting' : 'GPS Broadcasting Paused',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: ctrl.isOnline ? AppColors.primary : AppColors.error,
                  ),
                ),
                Text(
                  ctrl.isOnline
                      ? 'Live Telemetry: (34.6186, 71.9723) • High Precision'
                      : 'Turn switch online to receive dispatch alerts.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryHeroCard(BuildContext context, RiderDeliveryAssignment delivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(30)),
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
                    'Delivery #${delivery.orderNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      delivery.stage.displayName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.storeName,
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
                      'Drop-off: ${delivery.customerAddress}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cash: PKR ${delivery.cashToCollect.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Text(
                    'Earn: PKR ${delivery.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigo),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RiderDeliveryDetailScreen(delivery: delivery),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Route Detail'),
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
                        RiderDemoController.instance.progressDeliveryStage(delivery.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Updated to: ${delivery.stage.displayName}')),
                        );
                      },
                      child: Text(delivery.stage.nextActionLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoActiveDeliveryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(20)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.two_wheeler_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text(
              'No Active Delivery Right Now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay online to receive high-value orders in Batkhela.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
