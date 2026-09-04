import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../data/admin_demo_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    MarketplaceDataService.instance.notificationController.initSession(
      userId: 'ADMIN-ROOT-001',
      role: 'admin',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return AnimatedBuilder(
      animation: AdminDemoController.instance,
      builder: (context, _) {
        final ctrl = AdminDemoController.instance;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Row(
            children: [
              // Persistent Sidebar Navigation (Desktop)
              if (isDesktop) _buildSidebar(ctrl),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    _buildTopAppBar(isDesktop, ctrl),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildSelectedTabContent(ctrl),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          drawer: isDesktop ? null : Drawer(child: _buildSidebar(ctrl, isDrawer: true)),
        );
      },
    );
  }

  // ----------------------------------------------------
  // SIDEBAR NAVIGATION
  // ----------------------------------------------------
  Widget _buildSidebar(AdminDemoController ctrl, {bool isDrawer = false}) {
    return Container(
      width: 260,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BATKHELA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        'Super Admin Control',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),

          // Menu Items (9 Domains)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _navItem(0, Icons.dashboard_outlined, 'Overview'),
                _navItem(1, Icons.people_outline, 'Customers'),
                _navItem(2, Icons.storefront_outlined, 'Vendors',
                    badge: ctrl.vendors.where((v) => v.status == ApprovalStatus.pending).length),
                _navItem(3, Icons.two_wheeler_outlined, 'Riders',
                    badge: ctrl.riders.where((r) => r.status == ApprovalStatus.pending).length),
                _navItem(4, Icons.receipt_long_outlined, 'Orders'),
                _navItem(5, Icons.category_outlined, 'Categories'),
                _navItem(6, Icons.view_quilt_outlined, 'Homepage'),
                _navItem(7, Icons.campaign_outlined, 'Promotions'),
                _navItem(8, Icons.settings_outlined, 'Settings'),
              ],
            ),
          ),

          // Admin User Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0B1120),
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text('SA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform Admin',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Batkhela Central Hub',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String title, {int badge = 0}) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF94A3B8), size: 20),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          trailing: badge > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () {
            setState(() => _selectedTabIndex = index);
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isDesktop, AdminDemoController ctrl) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Expanded(
            child: Text(
              _getTabTitle(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Operational Notifications Bell
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
                    tooltip: 'Platform Operational Alerts',
                    onPressed: () => _showAdminNotificationsDialog(context),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
          const SizedBox(width: 12),
          // Live Node Telemetry Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Batkhela Node: LIVE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Operations Overview';
      case 1:
        return 'Customer Directory';
      case 2:
        return 'Vendor Management & Approvals';
      case 3:
        return 'Rider Fleet & Telemetry';
      case 4:
        return 'Platform Orders Center';
      case 5:
        return 'Marketplace Categories';
      case 6:
        return 'Dynamic Homepage Management';
      case 7:
        return 'Promotions & Banner Campaigns';
      case 8:
        return 'Platform Settings & Regional Expansion';
      default:
        return 'Super Admin Dashboard';
    }
  }

  Widget _buildSelectedTabContent(AdminDemoController ctrl) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(ctrl);
      case 1:
        return _buildCustomersTab(ctrl);
      case 2:
        return _buildVendorsTab(ctrl);
      case 3:
        return _buildRidersTab(ctrl);
      case 4:
        return _buildOrdersTab(ctrl);
      case 5:
        return _buildCategoriesTab(ctrl);
      case 6:
        return _buildHomepageTab(ctrl);
      case 7:
        return _buildPromotionsTab(ctrl);
      case 8:
        return _buildSettingsTab(ctrl);
      default:
        return _buildOverviewTab(ctrl);
    }
  }

  // ----------------------------------------------------
  // 1. OVERVIEW TAB
  // ----------------------------------------------------
  Widget _buildOverviewTab(AdminDemoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 6 Platform KPIs Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 1100
                ? (constraints.maxWidth - 32) / 3
                : (constraints.maxWidth > 650
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth);
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: 'Gross Platform GMV',
                    value: 'PKR ${ctrl.todayPlatformGmv.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.primary,
                    trend: '+16.8% vs yesterday',
                    isPositive: true,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: 'Platform Fee Revenue',
                    value: 'PKR ${ctrl.todayPlatformRevenue.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.indigo,
                    trend: '10% average take rate',
                    isPositive: true,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: 'Orders Today',
                    value: '${ctrl.todayOrdersCount} Orders',
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.coral,
                    trend: 'All in Batkhela',
                    isPositive: true,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: 'Active Vendors',
                    value: '${ctrl.activeVendorsCount} Stores',
                    icon: Icons.storefront_outlined,
                    iconColor: AppColors.primary,
                    trend: '${ctrl.vendors.where((v) => v.status == ApprovalStatus.pending).length} pending approval',
                    isPositive: true,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: 'Active Riders Online',
                    value: '${ctrl.activeRidersCount} Riders',
                    icon: Icons.two_wheeler_outlined,
                    iconColor: AppColors.indigo,
                    subtitle: 'Avg dispatch time: 6 mins',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: 'Registered Customers',
                    value: '${ctrl.totalCustomersCount} Users',
                    icon: Icons.people_outline,
                    iconColor: AppColors.coral,
                    trend: 'Batkhela Urban',
                    isPositive: true,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // Urgent Action Banner if approvals are pending
        if (ctrl.pendingApprovalsCount > 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.coral.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.coral.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ctrl.pendingApprovalsCount} Partner Applications Awaiting Review',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.coral),
                      ),
                      const Text(
                        'Verify vendor business credentials and rider CNIC documents to expand capacity.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => setState(() => _selectedTabIndex = 2),
                  child: const Text('Review Approvals'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Recent Realtime Orders Stream
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Realtime Orders Stream',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _selectedTabIndex = 4),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All Orders'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOrdersTable(ctrl.orders),
      ],
    );
  }

  // ----------------------------------------------------
  // 2. CUSTOMERS TAB
  // ----------------------------------------------------
  Widget _buildCustomersTab(AdminDemoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Management Directory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${ctrl.customers.length} Registered Customers',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(2.5),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                children: [
                  _tableHeader('Customer ID'),
                  _tableHeader('Name & Phone'),
                  _tableHeader('Batkhela Area'),
                  _tableHeader('Orders'),
                  _tableHeader('Total Spend'),
                  _tableHeader('Status'),
                ],
              ),
              ...ctrl.customers.map((c) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  children: [
                    _tableCell(c.id),
                    _tableCell('${c.name}\n${c.phone}', isBold: true),
                    _tableCell(c.area),
                    _tableCell('${c.totalOrders} orders'),
                    _tableCell('PKR ${c.totalSpend.toStringAsFixed(0)}', isBold: true),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Chip(
                        label: const Text('Active', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                        backgroundColor: AppColors.success.withAlpha(20),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // 3. VENDORS TAB
  // ----------------------------------------------------
  Widget _buildVendorsTab(AdminDemoController ctrl) {
    final pending = ctrl.vendors.where((v) => v.status == ApprovalStatus.pending).toList();
    final approved = ctrl.vendors.where((v) => v.status == ApprovalStatus.approved).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending Queue
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'Vendor Applications Pending Approval',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.coral),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.coral,
                child: Text('${pending.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pending.map((v) => _buildVendorApplicationCard(v, isPending: true)),
          const SizedBox(height: 24),
        ],

        // Approved Directory
        const Text(
          'Approved Marketplace Stores',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...approved.map((v) => _buildVendorApplicationCard(v, isPending: false)),
      ],
    );
  }

  Widget _buildVendorApplicationCard(AdminVendorApplication v, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isPending ? AppColors.coral.withAlpha(50) : const Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isPending ? AppColors.coral.withAlpha(20) : AppColors.primary.withAlpha(20),
              child: Icon(Icons.storefront, color: isPending ? AppColors.coral : AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(v.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(v.category, style: const TextStyle(fontSize: 11, color: AppColors.indigo, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Owner: ${v.ownerName} • Phone: ${v.phone}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  Text(v.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
            ),
            if (isPending) ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () {
                  AdminDemoController.instance.rejectVendor(v.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vendor ${v.businessName} rejected.')),
                  );
                },
                child: const Text('Reject'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  AdminDemoController.instance.approveVendor(v.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vendor ${v.businessName} Approved! Store is now live.')),
                  );
                },
                child: const Text('Approve Store'),
              ),
            ] else ...[
              Chip(
                label: const Text('Approved & Live', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.success.withAlpha(20),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 4. RIDERS TAB
  // ----------------------------------------------------
  Widget _buildRidersTab(AdminDemoController ctrl) {
    final pending = ctrl.riders.where((r) => r.status == ApprovalStatus.pending).toList();
    final approved = ctrl.riders.where((r) => r.status == ApprovalStatus.approved).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'Rider Applicants Awaiting Verification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.coral),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.coral,
                child: Text('${pending.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pending.map((r) => _buildRiderCard(r, isPending: true)),
          const SizedBox(height: 24),
        ],

        const Text(
          'Active Delivery Fleet Roster',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...approved.map((r) => _buildRiderCard(r, isPending: false)),
      ],
    );
  }

  Widget _buildRiderCard(AdminRiderApplication r, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isPending ? AppColors.coral.withAlpha(50) : const Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isPending ? AppColors.coral.withAlpha(20) : AppColors.indigo.withAlpha(20),
              child: Icon(Icons.two_wheeler, color: isPending ? AppColors.coral : AppColors.indigo),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(r.riderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${r.rating} ★', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${r.vehicleType} • Plate: ${r.plateNumber} • CNIC: ${r.cnic}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  Text('${r.completedTrips} deliveries completed', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
            ),
            if (isPending) ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () {
                  AdminDemoController.instance.rejectRider(r.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rider ${r.riderName} rejected.')),
                  );
                },
                child: const Text('Decline'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  AdminDemoController.instance.approveRider(r.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rider ${r.riderName} Approved for Batkhela dispatch!')),
                  );
                },
                child: const Text('Approve Rider'),
              ),
            ] else ...[
              Chip(
                label: const Text('Active Partner', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.success.withAlpha(20),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 5. ORDERS TAB
  // ----------------------------------------------------
  Widget _buildOrdersTab(AdminDemoController ctrl) {
    final filteredOrders = ctrl.orders.where((order) {
      final matchesStatus = _selectedStatusFilter == 'All' ||
          order.status.toDbString() == _selectedStatusFilter;
      final matchesQuery = _searchQuery.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.deliveryAddress.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesQuery;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by Order ID, Customer, or Delivery Area...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedStatusFilter,
              items: ['All', 'placed', 'preparing', 'out_for_delivery', 'delivered']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ').toUpperCase())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedStatusFilter = val ?? 'All'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildOrdersTable(filteredOrders),
      ],
    );
  }

  Widget _buildOrdersTable(List<MarketplaceOrder> orders) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.8),
          2: FlexColumnWidth(2.5),
          3: FlexColumnWidth(1.3),
          4: FlexColumnWidth(2.0),
          5: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            children: [
              _tableHeader('Order #'),
              _tableHeader('Store'),
              _tableHeader('Delivery Address'),
              _tableHeader('Amount'),
              _tableHeader('Status'),
              _tableHeader('Action'),
            ],
          ),
          ...orders.map((order) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              children: [
                _tableCell('#${order.orderNumber ?? order.id}'),
                _tableCell(order.vendorId == 'VEND-001' ? 'Shinwari Tikka' : 'Swat Grocery'),
                _tableCell(order.deliveryAddress),
                _tableCell('PKR ${order.totalAmount.toStringAsFixed(0)}', isBold: true),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: MarketplaceStatusBadge.fromOrderStatus(order.status),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Inspecting Order #${order.orderNumber ?? order.id}')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Details'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 6. CATEGORIES TAB
  // ----------------------------------------------------
  Widget _buildCategoriesTab(AdminDemoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Marketplace Category Catalog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Category'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...ctrl.categories.map((cat) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cat.isEnabled ? const Color(0xFFE2E8F0) : Colors.grey.shade300),
            ),
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cat.isEnabled ? AppColors.primary.withAlpha(20) : Colors.grey.shade200,
                child: Icon(Icons.category, color: cat.isEnabled ? AppColors.primary : Colors.grey),
              ),
              title: Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold, color: cat.isEnabled ? Colors.black87 : Colors.grey)),
              subtitle: Text('Display Order: ${cat.displayOrder} • ${cat.productCount} active products in Batkhela'),
              trailing: Switch(
                value: cat.isEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  ctrl.toggleCategory(cat.id, val);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Marketplace Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name (e.g. Traditional Sweets)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  AdminDemoController.instance.addCategory(nameController.text.trim(), 'store');
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create Category'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // 7. HOMEPAGE TAB
  // ----------------------------------------------------
  Widget _buildHomepageTab(AdminDemoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dynamic Customer Homepage Section Manager',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Configure homepage layout sections, enable seasonal feeds, and adjust marketplace discovery ordering.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        ...ctrl.homepageSections.map((sec) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.indigo.withAlpha(20),
                child: Text('${sec.displayOrder}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigo)),
              ),
              title: Text(sec.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Component Type: ${sec.sectionType}'),
              trailing: Switch(
                value: sec.isVisible,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  ctrl.toggleHomepageSection(sec.id, val);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // 8. PROMOTIONS TAB
  // ----------------------------------------------------
  Widget _buildPromotionsTab(AdminDemoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Banner Campaigns & Store Boosts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Campaign creation dialog opened.')),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Campaign'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...ctrl.promotions.map((prom) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.coral.withAlpha(20),
                    child: const Icon(Icons.campaign, color: AppColors.coral),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prom.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Merchant: ${prom.storeName}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(prom.discountBannerText, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Switch(
                    value: prom.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      ctrl.togglePromotion(prom.id, val);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // 9. SETTINGS TAB
  // ----------------------------------------------------
  Widget _buildSettingsTab(AdminDemoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform Governance & Regional Expansion',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Branding & Fee Settings Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marketplace Core Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Divider(height: 24),
                _buildSettingRow('App Name', ctrl.settings.marketplaceName),
                _buildSettingRow('Default Operations Hub', ctrl.settings.defaultCity),
                _buildSettingRow('Currency Token', ctrl.settings.currency),
                _buildSettingRow('Base Delivery Fee', 'PKR ${ctrl.settings.baseDeliveryFee.toStringAsFixed(0)}'),
                _buildSettingRow('Platform Commission Rate', '${ctrl.settings.platformCommissionPercent.toStringAsFixed(1)}%'),
                _buildSettingRow('Merchant Support Line', ctrl.settings.supportPhone),
                _buildSettingRow('Urdu Localization Readiness', ctrl.settings.urduEnabled ? 'Enabled (اردو / Noto Nastaliq)' : 'Disabled'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Multi-City Expansion Matrix
        const Text(
          'Regional Expansion Matrix',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...ctrl.regionalCities.map((city) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                city.isActive ? Icons.location_city : Icons.location_off_outlined,
                color: city.isActive ? AppColors.primary : Colors.grey,
              ),
              title: Text(city.cityName, style: TextStyle(fontWeight: FontWeight.bold, color: city.isActive ? Colors.black87 : Colors.grey)),
              subtitle: Text('${city.province} • ${city.vendorCount} Active Stores'),
              trailing: Switch(
                value: city.isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  ctrl.toggleRegionalCity(city.id, val);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _tableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13),
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showAdminNotificationsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 580,
            height: 600,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platform Operational Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Real-time system telemetry and incident stream',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await MarketplaceDataService.instance.notificationRepo.markAllAsRead(
                          userId: 'ADMIN-ROOT-001',
                        );
                      },
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Notifications List
                Expanded(
                  child: StreamBuilder<List<MarketplaceNotification>>(
                    stream: MarketplaceDataService.instance.notificationRepo.streamNotifications(
                      userId: 'ADMIN-ROOT-001',
                      role: 'admin',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final list = snapshot.data ?? [];
                      if (list.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none, size: 48, color: AppColors.textTertiary),
                              SizedBox(height: 12),
                              Text(
                                'No operational alerts',
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final isUnread = !item.isRead;

                          Color priorityColor;
                          IconData priorityIcon;
                          switch (item.priority) {
                            case NotificationPriority.urgent:
                              priorityColor = AppColors.coral;
                              priorityIcon = Icons.error_outline;
                              break;
                            case NotificationPriority.high:
                              priorityColor = Colors.orange;
                              priorityIcon = Icons.warning_amber_rounded;
                              break;
                            case NotificationPriority.normal:
                              priorityColor = AppColors.primary;
                              priorityIcon = Icons.info_outline;
                              break;
                            case NotificationPriority.low:
                              priorityColor = AppColors.textSecondary;
                              priorityIcon = Icons.notifications_none;
                              break;
                          }

                          return Container(
                            color: isUnread ? AppColors.primary.withAlpha(10) : Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: priorityColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(priorityIcon, color: priorityColor, size: 20),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.body,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                              onTap: () async {
                                if (isUnread) {
                                  await MarketplaceDataService.instance.notificationRepo.markAsRead(item.id);
                                }
                              },
                            ),
                          );
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
}
