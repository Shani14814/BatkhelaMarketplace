import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'phone_login_screen.dart';
import '../customer/customer_home_screen.dart';
import '../vendor/vendor_dashboard_screen.dart';
import '../rider/rider_home_screen.dart';
import '../role_selector_screen.dart';

/// Secure Authentication Gate for Mobile App
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: AuthService.instance.currentProfileNotifier,
      builder: (context, profile, _) {
        if (profile == null) {
          return const PhoneLoginScreen();
        }

        // Secure Role-based screen rendering
        switch (profile.role) {
          case UserRole.customer:
            return const CustomerHomeScreen();
          case UserRole.vendor:
            return const VendorDashboardScreen();
          case UserRole.rider:
            return const RiderHomeScreen();
          case UserRole.admin:
          case UserRole.superAdmin:
            return const RoleSelectorScreen();
        }
      },
    );
  }
}
