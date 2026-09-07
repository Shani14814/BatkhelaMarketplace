import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'phone_login_screen.dart';
import '../customer/customer_home_screen.dart';
import '../vendor/vendor_dashboard_screen.dart';
import 'vendor_pending_approval_screen.dart';
import 'rider_pending_approval_screen.dart';
import '../../data/vendor_demo_data.dart';
import '../../data/rider_demo_data.dart';
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
            return AnimatedBuilder(
              animation: VendorDemoController.instance,
              builder: (context, _) {
                if (VendorDemoController.instance.isCurrentVendorVerified) {
                  return const VendorDashboardScreen();
                } else {
                  return const VendorPendingApprovalScreen();
                }
              },
            );
          case UserRole.rider:
            return AnimatedBuilder(
              animation: RiderDemoController.instance,
              builder: (context, _) {
                if (RiderDemoController.instance.isCurrentRiderVerified) {
                  return const RiderHomeScreen();
                } else {
                  return const RiderPendingApprovalScreen();
                }
              },
            );
          case UserRole.admin:
          case UserRole.superAdmin:
            return const RoleSelectorScreen();
        }
      },
    );
  }
}
