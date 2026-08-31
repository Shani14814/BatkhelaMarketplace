import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';

class VendorMoreView extends StatelessWidget {
  const VendorMoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VendorDemoController.instance,
      builder: (context, _) {
        final ctrl = VendorDemoController.instance;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Store Operations & Hub',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section 1: Rider Network Management
              _buildRiderManagementSection(context, ctrl),
              const SizedBox(height: 16),

              // Section 2: Store Performance Analytics
              _buildAnalyticsSection(context, ctrl),
              const SizedBox(height: 16),

              // Section 3: Vendor Support & Merchant Tools
              _buildMerchantSupportSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiderManagementSection(BuildContext context, VendorDemoController ctrl) {
    final pendingRiders = ctrl.riderApplications
        .where((r) => r.status == RiderApplicationStatus.pending)
        .toList();
    final approvedRiders = ctrl.riderApplications
        .where((r) => r.status == RiderApplicationStatus.approved)
        .toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.two_wheeler_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Delivery Rider Network',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${approvedRiders.length} Active',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Batkhela delivery riders connected to your store for prompt order fulfillment.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 24, color: Color(0xFFF1F5F9)),

            // Pending Applications
            if (pendingRiders.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Pending Rider Requests',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.coral),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.coral,
                    child: Text(
                      '${pendingRiders.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...pendingRiders.map((rider) => _buildPendingRiderCard(context, rider)),
              const SizedBox(height: 12),
            ],

            // Approved Active Riders
            const Text(
              'Approved Delivery Partners',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...approvedRiders.map((rider) => _buildApprovedRiderTile(rider)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRiderCard(BuildContext context, DemoRiderApplication rider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.coral.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.coral.withAlpha(30),
                child: const Icon(Icons.person, color: AppColors.coral, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rider.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${rider.vehicleType} • CNIC: ${rider.cnic}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  VendorDemoController.instance.rejectRider(rider.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Application from ${rider.name} rejected.')),
                  );
                },
                child: const Text('Decline'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  VendorDemoController.instance.approveRider(rider.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rider ${rider.name} approved for deliveries!')),
                  );
                },
                child: const Text('Approve Rider'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedRiderTile(DemoRiderApplication rider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rider.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${rider.vehicleType} • ${rider.completedDeliveries} deliveries completed',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 2),
              Text(
                '${rider.rating}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, VendorDemoController ctrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Sales & Operational Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softCyan.withAlpha(45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Avg Order Value', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        const Text('PKR 1,740', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 2),
                        Text('+12% vs last week', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Items Sold', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        const Text('38 Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.indigo)),
                        const SizedBox(height: 2),
                        Text('Batkhela Lunch Peak', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFF1F5F9)),
            const Text(
              'Top Selling Items Today',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildTopItemRow('1. Shinwari Mutton Karahi', '14 orders', 'PKR 30,100'),
            _buildTopItemRow('2. Dumba Namkeen Tikka', '11 orders', 'PKR 6,380'),
            _buildTopItemRow('3. Peshawari Chapli Kabab', '8 orders', 'PKR 1,440'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopItemRow(String name, String volume, String revenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Text(volume, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 16),
          Text(revenue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildMerchantSupportSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.support_agent, color: AppColors.primary),
            title: const Text('Batkhela Merchant Helpline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Direct phone support for market vendors', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dialing Batkhela Merchant Support (+92 932 410000)...')),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('Language / زبان', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('English / اردو / پښتو', style: TextStyle(fontSize: 12)),
            trailing: const Text('English', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vendor portal localization settings')),
              );
            },
          ),
        ],
      ),
    );
  }
}
