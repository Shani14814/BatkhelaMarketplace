import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';

  // Sample operational mock data for dashboard presentation
  final List<MarketplaceOrder> _mockOrders = [
    MarketplaceOrder(
      id: 'ORD-8821',
      orderNumber: 1042,
      customerId: 'CUST-001',
      vendorId: 'VEND-001',
      subtotal: 1850.0,
      deliveryFee: 120.0,
      platformFee: 50.0,
      totalAmount: 2020.0,
      status: OrderStatus.outForDelivery,
      deliveryAddress: 'Main Bazaar Road, Near GPO, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    MarketplaceOrder(
      id: 'ORD-8820',
      orderNumber: 1041,
      customerId: 'CUST-002',
      vendorId: 'VEND-002',
      subtotal: 940.0,
      deliveryFee: 100.0,
      platformFee: 30.0,
      totalAmount: 1070.0,
      status: OrderStatus.preparing,
      deliveryAddress: 'Thana By-Pass Chowk, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
    ),
    MarketplaceOrder(
      id: 'ORD-8819',
      orderNumber: 1040,
      customerId: 'CUST-003',
      vendorId: 'VEND-001',
      subtotal: 3200.0,
      deliveryFee: 150.0,
      platformFee: 90.0,
      totalAmount: 3440.0,
      status: OrderStatus.delivered,
      deliveryAddress: 'Civil Hospital Colony, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    MarketplaceOrder(
      id: 'ORD-8818',
      orderNumber: 1039,
      customerId: 'CUST-004',
      vendorId: 'VEND-003',
      subtotal: 650.0,
      deliveryFee: 80.0,
      platformFee: 20.0,
      totalAmount: 750.0,
      status: OrderStatus.placed,
      deliveryAddress: 'Ziarat Road, Mohalla Khanan, Batkhela',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<Vendor> _mockVendors = [
    Vendor(
      id: 'VEND-001',
      storeName: 'Batkhela Shinwari Tikka & Karahi',
      slug: 'batkhela-shinwari',
      address: 'Main Grand Trunk Road, Batkhela',
      phone: '+92 345 9876543',
      isVerified: true,
      isOpen: true,
      commissionRate: 10.0,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Vendor(
      id: 'VEND-002',
      storeName: 'Swat Valley Fresh Grocery & Fruits',
      slug: 'swat-fresh-grocery',
      address: 'Sabzi Mandi Road, Batkhela',
      phone: '+92 300 1234567',
      isVerified: true,
      isOpen: true,
      commissionRate: 8.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Vendor(
      id: 'VEND-003',
      storeName: 'Malakand Bakers & Sweets',
      slug: 'malakand-bakers',
      address: 'College Road, Batkhela',
      phone: '+92 312 3456789',
      isVerified: false,
      isOpen: true,
      commissionRate: 10.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation (for Desktop/Tablet)
          if (isDesktop) _buildSidebar(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildTopAppBar(isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildSelectedTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(isDrawer: true)),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
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
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATKHELA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _navItem(0, Icons.dashboard_outlined, 'Operations Overview'),
                _navItem(1, Icons.shopping_bag_outlined, 'Live Orders'),
                _navItem(2, Icons.store_outlined, 'Vendor Stores'),
                _navItem(3, Icons.two_wheeler_outlined, 'Rider Fleet'),
                _navItem(4, Icons.account_balance_wallet_outlined, 'Financials & Payouts'),
                _navItem(5, Icons.settings_outlined, 'Platform Settings'),
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
                  backgroundColor: AppTheme.primaryGreen,
                  child: Text('SA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Operations',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Batkhela Central',
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

  Widget _navItem(int index, IconData icon, String title) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTopAppBar(bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Text(
            _getTabTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const Spacer(),
          // Live Realtime Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.successGreen.withAlpha(60)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppTheme.successGreen),
                SizedBox(width: 8),
                Text(
                  'Batkhela Node: LIVE',
                  style: TextStyle(
                    color: AppTheme.successGreen,
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
        return 'Operations Dashboard';
      case 1:
        return 'Live Orders & Dispatch';
      case 2:
        return 'Store & Vendor Directory';
      case 3:
        return 'Rider Fleet & Telemetry';
      case 4:
        return 'Financials & Commissions';
      case 5:
        return 'Marketplace Configuration';
      default:
        return 'Admin Dashboard';
    }
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildOrdersTab();
      case 2:
        return _buildVendorsTab();
      case 3:
        return _buildRidersTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Cards Row
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 1100
                ? (constraints.maxWidth - 48) / 4
                : (constraints.maxWidth > 650
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth);
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const KpiCard(
                    title: 'Gross Daily Sales',
                    value: 'Rs. 48,250',
                    icon: Icons.payments_outlined,
                    iconColor: AppTheme.primaryGreen,
                    trend: '+14.2% vs yesterday',
                    isPositive: true,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const KpiCard(
                    title: 'Active Orders',
                    value: '19 Orders',
                    icon: Icons.local_shipping_outlined,
                    iconColor: AppTheme.statusOutForDelivery,
                    subtitle: '4 out for delivery',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const KpiCard(
                    title: 'Registered Stores',
                    value: '34 Vendors',
                    icon: Icons.storefront_outlined,
                    iconColor: AppTheme.accentGold,
                    trend: '+3 pending approval',
                    isPositive: true,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const KpiCard(
                    title: 'Active Riders Online',
                    value: '12 Riders',
                    icon: Icons.electric_moped_outlined,
                    iconColor: Color(0xFF0284C7),
                    subtitle: 'Avg delivery: 24 mins',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // Live Orders Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Realtime Orders Stream',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _selectedTabIndex = 1),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All Orders'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOrdersTable(_mockOrders),
      ],
    );
  }

  Widget _buildOrdersTab() {
    final filteredOrders = _mockOrders.where((order) {
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
        // Filter Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by Order ID, Customer Phone, or Store...',
                  prefixIcon: Icon(Icons.search, size: 20),
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
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(2.0),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.3),
          5: FlexColumnWidth(1.2),
        },
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
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
          // Rows
          ...orders.map((order) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              children: [
                _tableCell('#${order.orderNumber ?? order.id}'),
                _tableCell(order.vendorId == 'VEND-001' ? 'Shinwari Tikka' : 'Swat Grocery'),
                _tableCell(order.deliveryAddress),
                _tableCell('Rs. ${order.totalAmount.toStringAsFixed(0)}', isBold: true),
                _statusBadge(order.status),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: OutlinedButton(
                    onPressed: () {},
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

  Widget _buildVendorsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Store Directory & Verification Queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Store'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._mockVendors.map((vendor) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withAlpha(30),
                child: const Icon(Icons.store, color: AppTheme.primaryGreen),
              ),
              title: Text(vendor.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${vendor.address} • ${vendor.phone ?? 'No Phone'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      vendor.isVerified ? 'Verified' : 'Pending Verification',
                      style: TextStyle(
                        color: vendor.isVerified ? AppTheme.successGreen : AppTheme.statusPreparing,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: (vendor.isVerified ? AppTheme.successGreen : AppTheme.statusPreparing).withAlpha(20),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRidersTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Batkhela Rider Fleet & Live GPS Radar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Riders connected via Supabase Realtime channel stream live coordinates to this central monitoring board.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          SizedBox(height: 24),
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.radar, size: 64, color: AppTheme.primaryGreen),
                  SizedBox(height: 12),
                  Text('12 Active Riders Broadcasting Live Telemetry', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('Batkhela Center Coordinates: 34.6186° N, 71.9723° E', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textMuted, fontSize: 13),
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
          color: AppTheme.textDark,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case OrderStatus.placed:
        bg = AppTheme.statusPlaced.withAlpha(25);
        fg = AppTheme.statusPlaced;
        break;
      case OrderStatus.preparing:
        bg = AppTheme.statusPreparing.withAlpha(25);
        fg = AppTheme.statusPreparing;
        break;
      case OrderStatus.outForDelivery:
        bg = AppTheme.statusOutForDelivery.withAlpha(25);
        fg = AppTheme.statusOutForDelivery;
        break;
      case OrderStatus.delivered:
        bg = AppTheme.statusDelivered.withAlpha(25);
        fg = AppTheme.statusDelivered;
        break;
      case OrderStatus.cancelled:
        bg = AppTheme.statusCancelled.withAlpha(25);
        fg = AppTheme.statusCancelled;
        break;
      default:
        bg = Colors.grey.withAlpha(25);
        fg = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          status.displayName,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
