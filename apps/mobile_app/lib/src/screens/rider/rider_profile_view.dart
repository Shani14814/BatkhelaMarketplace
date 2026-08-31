import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';

class RiderProfileView extends StatelessWidget {
  const RiderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final ctrl = RiderDemoController.instance;
        final profile = ctrl.profile;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title: const Text('Rider Profile & Hub', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Header Card
              _buildProfileHeaderCard(context, profile, ctrl),
              const SizedBox(height: 16),

              // Vehicle & Equipment Card
              _buildVehicleCard(context, profile),
              const SizedBox(height: 16),

              // Delivery Operational Performance Card
              _buildPerformanceCard(context, profile),
              const SizedBox(height: 16),

              // Settings & Emergency Support
              _buildSettingsAndSupportSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, RiderProfile profile, RiderDemoController ctrl) {
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
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.two_wheeler, size: 36, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          if (profile.isVerified)
                            const Icon(Icons.verified, size: 18, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Batkhela Registered Delivery Partner',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.phone,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigo),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Online Radar Broadcasting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Switch(
                  value: ctrl.isOnline,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    ctrl.toggleOnlineStatus(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? 'Rider radar is ONLINE' : 'Rider radar is OFFLINE')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, RiderProfile profile) {
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
            const Row(
              children: [
                Icon(Icons.directions_bike, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Vehicle & Registration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildProfileInfoRow('Vehicle', profile.vehicleModel),
            _buildProfileInfoRow('Registration Plate', profile.licenseNumber),
            _buildProfileInfoRow('CNIC Verification', profile.cnic),
            _buildProfileInfoRow('Service Zone', 'Batkhela Urban & Main Bypass'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context, RiderProfile profile) {
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
            const Row(
              children: [
                Icon(Icons.star, color: AppColors.warning),
                SizedBox(width: 8),
                Text(
                  'Delivery Rating & Reliability',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn('${profile.rating} ★', 'Customer Rating'),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                _buildMetricColumn('${profile.completedDeliveriesCount}', 'Total Completed'),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                _buildMetricColumn('99.2%', 'On-Time Rate'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSettingsAndSupportSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.emergency, color: AppColors.error),
            title: const Text('24/7 Rider Emergency Helpline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error)),
            subtitle: const Text('Direct Batkhela dispatch emergency desk', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to Rider Emergency Dispatch...')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('Language Preference', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text('English / اردو / پښتو', style: TextStyle(fontSize: 11)),
            trailing: const Text('English', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rider app localization settings')),
              );
            },
          ),
        ],
      ),
    );
  }
}
