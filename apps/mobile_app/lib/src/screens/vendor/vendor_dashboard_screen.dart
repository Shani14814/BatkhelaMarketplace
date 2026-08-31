import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';
import 'vendor_order_detail_screen.dart';
import 'vendor_products_view.dart';
import 'vendor_business_view.dart';
import 'vendor_more_view.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VendorDemoController.instance,
      builder: (context, _) {
        final ctrl = VendorDemoController.instance;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboardTab(context, ctrl),
              _buildOrdersTab(context, ctrl),
              const VendorProductsView(),
              const VendorBusinessView(),
              const VendorMoreView(),
            ],
          ),
          bottomNavigationBar: MarketplaceBottomNav(
            currentIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: [
              const MarketplaceNavDestination(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
              ),
              MarketplaceNavDestination(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Orders',
                badgeCount: ctrl.pendingOrdersCount > 0 ? ctrl.pendingOrdersCount : null,
              ),
              const MarketplaceNavDestination(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Products',
              ),
              const MarketplaceNavDestination(
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                label: 'Business',
              ),
              MarketplaceNavDestination(
                icon: Icons.more_horiz,
                activeIcon: Icons.more_horiz,
                label: 'More',
                badgeCount: ctrl.riderApplications.where((r) => r.status == RiderApplicationStatus.pending).isNotEmpty
                    ? ctrl.riderApplications.where((r) => r.status == RiderApplicationStatus.pending).length
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 0: DASHBOARD
  // ----------------------------------------------------
  Widget _buildDashboardTab(BuildContext context, VendorDemoController ctrl) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
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
              child: const Icon(Icons.storefront, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ctrl.store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ctrl.store.isOpen ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ctrl.store.isOpen ? 'ONLINE • Accepting Orders' : 'OFFLINE • Paused',
                        style: TextStyle(
                          fontSize: 11,
                          color: ctrl.store.isOpen ? AppColors.primary : AppColors.error,
                          fontWeight: FontWeight.bold,
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
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Switch(
                  value: ctrl.store.isOpen,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.softCyan,
                  onChanged: (val) {
                    ctrl.toggleStoreOpenStatus(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryDark,
                        content: Text(val
                            ? 'Store is ONLINE & visible to Batkhela customers'
                            : 'Store is OFFLINE. New orders are paused.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Store Status Banner
          _buildStoreStatusBanner(context, ctrl),
          const SizedBox(height: 16),

          // Operational KPI Metrics (4 Cards Grid in 2x2)
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: "Today's Sales",
                  value: 'PKR ${ctrl.todayRevenue.toStringAsFixed(0)}',
                  trend: '+18% vs yesterday',
                  isPositive: true,
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Active Orders',
                  value: '${ctrl.activeOrdersCount}',
                  trend: ctrl.pendingOrdersCount > 0
                      ? '${ctrl.pendingOrdersCount} urgent pending'
                      : 'All in preparation',
                  isPositive: ctrl.pendingOrdersCount == 0,
                  icon: Icons.receipt_long_outlined,
                  iconColor: AppColors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Store Rating',
                  value: '${ctrl.store.rating} ★',
                  trend: '${ctrl.store.reviewCount} verified reviews',
                  isPositive: true,
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Active Menu Items',
                  value: '${ctrl.products.where((p) => p.isAvailable).length} / ${ctrl.products.length}',
                  trend: 'All in stock & live',
                  isPositive: true,
                  icon: Icons.restaurant_menu,
                  iconColor: AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Operations Section
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
                  label: 'Orders Queue',
                  icon: Icons.receipt_long,
                  badgeCount: ctrl.pendingOrdersCount > 0 ? ctrl.pendingOrdersCount : null,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VendorQuickActionButton(
                  label: 'Add Product',
                  icon: Icons.add_box_outlined,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: VendorQuickActionButton(
                  label: 'Store Profile',
                  icon: Icons.storefront_outlined,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VendorQuickActionButton(
                  label: 'Riders Hub',
                  icon: Icons.two_wheeler_outlined,
                  badgeCount: ctrl.riderApplications.where((r) => r.status == RiderApplicationStatus.pending).isNotEmpty
                      ? ctrl.riderApplications.where((r) => r.status == RiderApplicationStatus.pending).length
                      : null,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Urgent Action Banner if orders are pending
          if (ctrl.pendingOrdersCount > 0) ...[
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
                    child: const Icon(Icons.notifications_active, color: AppColors.coral, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ctrl.pendingOrdersCount} New Orders Awaiting Acceptance',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Review and accept to notify kitchen and dispatch riders immediately.',
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
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Recent Live Orders Header & Preview List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Live Orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _currentIndex = 1),
                icon: const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                label: const Text(
                  'View Queue',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...ctrl.orders.take(3).map((order) => _buildVendorOrderCard(context, order)),
        ],
      ),
    );
  }

  Widget _buildStoreStatusBanner(BuildContext context, VendorDemoController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ctrl.store.isOpen ? AppColors.softCyan.withAlpha(45) : AppColors.error.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ctrl.store.isOpen ? AppColors.primary.withAlpha(40) : AppColors.error.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ctrl.store.isOpen ? AppColors.primary.withAlpha(20) : AppColors.error.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ctrl.store.isOpen ? Icons.check_circle_outline : Icons.pause_circle_outline,
              color: ctrl.store.isOpen ? AppColors.primary : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.store.isOpen ? 'Store Active on Batkhela Marketplace' : 'Store is Closed to Customers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: ctrl.store.isOpen ? AppColors.primary : AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ctrl.store.isOpen
                      ? 'Live at: ${ctrl.store.address} • Instant orders active'
                      : 'Switch toggle to re-open during operational hours.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 1: ORDERS MANAGEMENT QUEUE
  // ----------------------------------------------------
  Widget _buildOrdersTab(BuildContext context, VendorDemoController ctrl) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Order Management',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: [
              Tab(text: 'All Orders'),
              Tab(text: 'New (Pending)'),
              Tab(text: 'Preparing'),
              Tab(text: 'Ready for Rider'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersFilteredList(context, ctrl.orders),
            _buildOrdersFilteredList(context, ctrl.orders.where((o) => o.status == OrderStatus.placed).toList()),
            _buildOrdersFilteredList(
                context, ctrl.orders.where((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.preparing).toList()),
            _buildOrdersFilteredList(context, ctrl.orders.where((o) => o.status == OrderStatus.readyForPickup).toList()),
            _buildOrdersFilteredList(
                context, ctrl.orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersFilteredList(BuildContext context, List<MarketplaceOrder> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No orders in this stage',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildVendorOrderCard(context, list[index]),
    );
  }

  Widget _buildVendorOrderCard(BuildContext context, MarketplaceOrder order) {
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
              builder: (_) => VendorOrderDetailScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Number & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber ?? order.id}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  MarketplaceStatusBadge.fromOrderStatus(order.status),
                ],
              ),
              const SizedBox(height: 8),

              // Customer & Location Area
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 15, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Customer: ${order.customerId} • ${order.deliveryAddress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),

              // Items Summary
              if (order.items.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.items.map((i) => '${i.quantity}x ${i.productName}').join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                  ),
                ),
              ],

              // Customer Special Notes
              if (order.customerNotes != null && order.customerNotes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.coral.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notes, size: 14, color: AppColors.coral),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Note: ${order.customerNotes}',
                          style: const TextStyle(fontSize: 11, color: AppColors.coral, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 24, color: Color(0xFFF1F5F9)),

              // Price & Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      Text(
                        'PKR ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  _buildInlineActionButtons(context, order),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineActionButtons(BuildContext context, MarketplaceOrder order) {
    if (order.status == OrderStatus.placed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              VendorDemoController.instance.rejectOrder(order.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order Rejected.')),
              );
            },
            child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              VendorDemoController.instance.acceptOrder(order.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order Accepted! Kitchen preparing.')),
              );
            },
            child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    } else if (order.status == OrderStatus.accepted) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          VendorDemoController.instance.startPreparing(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order is now cooking in kitchen!')),
          );
        },
        child: const Text('Start Cooking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    } else if (order.status == OrderStatus.preparing) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          VendorDemoController.instance.markReadyForPickup(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked Ready! Dispatched notification to rider.')),
          );
        },
        child: const Text('Mark Ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    }
    return const Icon(Icons.chevron_right, color: AppColors.textTertiary);
  }
}
