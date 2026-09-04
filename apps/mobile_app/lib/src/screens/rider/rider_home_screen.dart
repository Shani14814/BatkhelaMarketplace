import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import '../../widgets/notification_inbox_sheet.dart';
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
  StreamSubscription<LocationCoordinates>? _locationSub;
  LocationCoordinates? _liveCoords;

  @override
  void initState() {
    super.initState();
    MarketplaceDataService.instance.notificationController.initSession(
      userId: 'usr_rider_1',
      role: 'rider',
    );
    _initRiderTracking();
  }

  void _initRiderTracking() {
    final tracker = MarketplaceDataService.instance.riderLocationTracker;
    final ctrl = RiderDemoController.instance;

    if (ctrl.isOnline) {
      tracker.startTracking('RIDER-DEMO-001');
    }

    _locationSub = tracker.coordinatesStream.listen((coords) {
      if (mounted) {
        setState(() {
          _liveCoords = coords;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    MarketplaceDataService.instance.riderLocationTracker.stopTracking();
    super.dispose();
  }

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
            destinations: [
              const MarketplaceNavDestination(
                icon: Icons.radar_outlined,
                activeIcon: Icons.radar,
                label: 'Radar',
              ),
              MarketplaceNavDestination(
                icon: Icons.two_wheeler_outlined,
                activeIcon: Icons.two_wheeler,
                label: 'Deliveries',
                badgeCount: ctrl.offeredAssignments.isNotEmpty ? ctrl.offeredAssignments.length : null,
              ),
              const MarketplaceNavDestination(
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments,
                label: 'Earnings',
              ),
              const MarketplaceNavDestination(
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
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Rider Delivery Radar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ctrl.isOnline ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          ctrl.isOnline ? 'ONLINE • Radar Active' : 'OFFLINE • Paused',
                          style: TextStyle(
                            fontSize: 11,
                            color: ctrl.isOnline ? AppColors.primary : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<int>(
            stream: MarketplaceDataService.instance.notificationController.unreadCountStream,
            initialData: MarketplaceDataService.instance.notificationController.currentUnreadCount,
            builder: (context, snapshot) {
              final unread = snapshot.data ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                    tooltip: 'Notifications',
                    onPressed: () {
                      NotificationInboxSheet.show(
                        context,
                        userId: 'usr_rider_1',
                        role: 'rider',
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.coral,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Switch(
              value: ctrl.isOnline,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.softCyan,
              onChanged: (val) {
                ctrl.toggleOnlineStatus(val);
                final tracker = MarketplaceDataService.instance.riderLocationTracker;
                if (val) {
                  tracker.startTracking('RIDER-DEMO-001');
                } else {
                  tracker.stopTracking();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primaryDark,
                    content: Text(val ? 'Rider radar is ONLINE and broadcasting GPS' : 'Rider radar is OFFLINE'),
                  ),
                );
              },
            ),
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
                  trend: '${ctrl.profile.rating} ★ Partner Rating',
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.coral.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.coral.withAlpha(60)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notification_important, color: AppColors.coral, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$offeredCount New Delivery Assignment Offered',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Review and accept to start pickup immediately.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: const Text('View Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Active Delivery Hero Card
        const Text(
          'Current Assigned Delivery',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: -0.2,
          ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: -0.2,
          ),
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
    final lat = _liveCoords?.latitude ?? 34.6186;
    final lng = _liveCoords?.longitude ?? 71.9723;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ctrl.isOnline ? AppColors.softCyan.withAlpha(45) : AppColors.error.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ctrl.isOnline ? AppColors.primary.withAlpha(40) : AppColors.error.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ctrl.isOnline ? AppColors.primary.withAlpha(20) : AppColors.error.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ctrl.isOnline ? Icons.gps_fixed : Icons.gps_off,
              color: ctrl.isOnline ? AppColors.primary : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.isOnline ? 'Broadcasting Location in Batkhela' : 'Telemetry Paused',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: ctrl.isOnline ? AppColors.primary : AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ctrl.isOnline
                      ? 'GPS: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E • High Accuracy'
                      : 'Switch online toggle to start receiving delivery dispatches.',
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
        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                    'Trip #${delivery.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      delivery.stage.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(delivery.storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(delivery.pickupAddress, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(delivery.customerArea, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(delivery.customerAddress, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimated Payout', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      Text(
                        'PKR ${delivery.totalEarnings.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RiderDeliveryDetailScreen(delivery: delivery),
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigation_outlined, size: 16),
                    label: const Text('Open Route', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softCyan.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'No active delivery right now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep online status enabled. New delivery dispatches will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
