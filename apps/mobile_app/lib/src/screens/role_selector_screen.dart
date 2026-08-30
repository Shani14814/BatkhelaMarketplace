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
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.storefront, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'BATKHELA MARKETPLACE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select role to test mobile application flow',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 36),

              // Role Cards
              _roleCard(
                context,
                title: 'Customer Experience',
                subtitle: 'Browse stores, order food & groceries, track delivery',
                icon: Icons.person_outline,
                target: const CustomerHomeScreen(),
              ),
              const SizedBox(height: 12),
              _roleCard(
                context,
                title: 'Vendor Store Portal',
                subtitle: 'Manage catalog, accept orders & view store analytics',
                icon: Icons.storefront_outlined,
                target: const VendorDashboardScreen(),
              ),
              const SizedBox(height: 12),
              _roleCard(
                context,
                title: 'Rider Delivery App',
                subtitle: 'Broadcast GPS radar, accept jobs, navigate routes',
                icon: Icons.two_wheeler_outlined,
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
    required Widget target,
  }) {
    return Card(
      color: Colors.white.withAlpha(240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withAlpha(30),
          child: Icon(icon, color: AppTheme.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute<void>(builder: (_) => target));
        },
      ),
    );
  }
}
