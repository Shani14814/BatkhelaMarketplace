import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../customer/customer_home_screen.dart';
import '../vendor/vendor_dashboard_screen.dart';
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
        destination = const VendorDashboardScreen();
        break;
      case UserRole.rider:
        destination = const RiderHomeScreen();
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
