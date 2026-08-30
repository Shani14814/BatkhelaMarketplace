import '../models/user_profile.dart';

/// Centralized Declarative Route Paths for Batkhela Marketplace
class AppRoutes {
  // Public & Authentication
  static const String root = '/';
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String roleSelector = '/role-selector';

  // Customer Experience
  static const String customerHome = '/customer/home';
  static const String customerStore = '/customer/store/:storeId';
  static const String customerCart = '/customer/cart';
  static const String customerCheckout = '/customer/checkout';
  static const String customerOrders = '/customer/orders';
  static const String customerOrderDetail = '/customer/orders/:orderId';

  // Vendor Portal
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorCatalog = '/vendor/catalog';
  static const String vendorSettings = '/vendor/settings';

  // Rider Delivery App
  static const String riderRadar = '/rider/radar';
  static const String riderActiveJob = '/rider/active-job';
  static const String riderEarnings = '/rider/earnings';

  // Super Admin Web Dashboard
  static const String adminOverview = '/admin/overview';
  static const String adminOrders = '/admin/orders';
  static const String adminVendors = '/admin/vendors';
  static const String adminRiders = '/admin/riders';
  static const String adminFinancials = '/admin/financials';
  static const String adminSettings = '/admin/settings';
}

/// Role-aware Route Guard Architecture
class RouteGuard {
  static bool canAccessRoute({
    required String path,
    required UserRole? userRole,
  }) {
    if (path.startsWith('/admin')) {
      return userRole == UserRole.admin || userRole == UserRole.superAdmin;
    }
    if (path.startsWith('/vendor')) {
      return userRole == UserRole.vendor || userRole == UserRole.admin || userRole == UserRole.superAdmin;
    }
    if (path.startsWith('/rider')) {
      return userRole == UserRole.rider || userRole == UserRole.admin || userRole == UserRole.superAdmin;
    }
    return true; // Public or Customer routes
  }
}
