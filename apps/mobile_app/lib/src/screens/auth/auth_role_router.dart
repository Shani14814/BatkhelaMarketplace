import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../customer/customer_home_screen.dart';
import '../vendor/vendor_dashboard_screen.dart';
import 'vendor_pending_approval_screen.dart';
import 'rider_pending_approval_screen.dart';
import '../../data/vendor_demo_data.dart';
import '../../data/rider_demo_data.dart';
import '../rider/rider_home_screen.dart';
import '../role_selector_screen.dart';

/// Secure Role-Based Navigation Router for Mobile Application
class AuthRoleRouter {
  static void navigateForRole(BuildContext context, UserRole role) {
    Widget destination;

    switch (role) {
      case UserRole.customer:
        destination = const CustomerHomeScreen();
        break;
      case UserRole.vendor:
        destination = VendorDemoController.instance.isCurrentVendorVerified
            ? const VendorDashboardScreen()
            : const VendorPendingApprovalScreen();
        break;
      case UserRole.rider:
        destination = RiderDemoController.instance.isCurrentRiderVerified
            ? const RiderHomeScreen()
            : const RiderPendingApprovalScreen();
        break;
      case UserRole.admin:
      case UserRole.superAdmin:
        destination = const RoleSelectorScreen();
        break;
    }

    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => destination),
      (route) => false,
    );
  }
}
