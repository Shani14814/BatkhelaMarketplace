import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';

class RiderEarningsView extends StatelessWidget {
  const RiderEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final ctrl = RiderDemoController.instance;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title: const Text('Activity & Earnings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Hero Balance Card
              _buildBalanceSummaryCard(context, ctrl),
              const SizedBox(height: 16),

              // Weekly Activity Overview Grid
              _buildWeeklySummaryGrid(context, ctrl),
              const SizedBox(height: 16),

              // Earnings Breakdown
              _buildEarningsBreakdownCard(context, ctrl),
              const SizedBox(height: 16),

              // Completed Deliveries History
              _buildDeliveryHistorySection(context, ctrl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSummaryCard(BuildContext context, RiderDemoController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Net Earnings",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, size: 12, color: AppColors.softCyan),
                    SizedBox(width: 4),
                    Text('Batkhela Instant Pay', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PKR ${ctrl.todayEarnings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${ctrl.todayCompletedCount} Completed Deliveries Today',
                style: const TextStyle(color: AppColors.softCyan, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryGrid(BuildContext context, RiderDemoController ctrl) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Week', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                const Text('PKR 8,420', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text('54 trips completed', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Average / Trip', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                const Text('PKR 155', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigo)),
                const SizedBox(height: 4),
                Text('Top 5% in Batkhela', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsBreakdownCard(BuildContext context, RiderDemoController ctrl) {
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
              'Earnings Structure',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Divider(height: 20),
            _buildBreakdownRow('Base Delivery Fees', 'PKR 6,800', Icons.two_wheeler_outlined),
            _buildBreakdownRow('Customer Cash Tips', 'PKR 1,120', Icons.favorite_outline),
            _buildBreakdownRow('Peak Hour Fuel Allowance', 'PKR 500', Icons.local_gas_station_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String title, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDeliveryHistorySection(BuildContext context, RiderDemoController ctrl) {
    final history = ctrl.completedAssignments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Completed Deliveries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No completed deliveries recorded today.')),
          )
        else
          ...history.map((d) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary.withAlpha(15)),
              ),
              color: Colors.white,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: AppColors.success),
                ),
                title: Text(
                  'Order #${d.orderNumber} • ${d.storeName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  '${d.customerArea} • ${d.distanceKm} km',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                trailing: Text(
                  '+PKR ${d.totalEarnings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
