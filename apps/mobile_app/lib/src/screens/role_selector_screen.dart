import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'customer/customer_home_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';
import 'rider/rider_home_screen.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, Color(0xFF0D131A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.roundedXl,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33006D77),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.storefront, size: 48, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'BATKHELA MARKETPLACE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Select role to test mobile application flow',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Role Cards
              _roleCard(
                context,
                title: 'Customer Experience',
                subtitle: 'Browse stores, order food & groceries, track delivery',
                icon: Icons.person_outline,
                badgeColor: AppColors.customerBadge,
                role: UserRole.customer,
                target: const CustomerHomeScreen(),
              ),
              const SizedBox(height: AppSpacing.md),
              _roleCard(
                context,
                title: 'Vendor Store Portal',
                subtitle: 'Manage catalog, accept orders & view store analytics',
                icon: Icons.storefront_outlined,
                badgeColor: AppColors.vendorBadge,
                role: UserRole.vendor,
                target: const VendorDashboardScreen(),
              ),
              const SizedBox(height: AppSpacing.md),
              _roleCard(
                context,
                title: 'Rider Delivery App',
                subtitle: 'Broadcast GPS radar, accept jobs, navigate routes',
                icon: Icons.two_wheeler_outlined,
                badgeColor: AppColors.riderBadge,
                role: UserRole.rider,
                target: const RiderHomeScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
    required UserRole role,
    required Widget target,
  }) {
    return Card(
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: CircleAvatar(
          backgroundColor: badgeColor.withAlpha(25),
          child: Icon(icon, color: badgeColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
        onTap: () async {
          await AuthService.instance.signInDemo(role);
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => target));
          }
        },
      ),
    );
  }
}
