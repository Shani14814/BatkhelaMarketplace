import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  group('Authentication & Security Architecture Tests', () {
    late DemoAuthRepository repo;

    setUp(() {
      repo = DemoAuthRepository();
      AuthService.instance.initialize(
        repository: repo,
        isDemoMode: true,
      );
    });

    tearDown(() {
      repo.dispose();
    });

    test('Initial unauthenticated state', () {
      expect(AuthService.instance.isAuthenticated, isFalse);
      expect(AuthService.instance.currentProfile, isNull);
      expect(AuthService.instance.currentRole, equals(UserRole.customer));
    });

    test('Demo Phone OTP flow produces Customer role', () async {
      final sendSuccess = await AuthService.instance.sendPhoneOtp('+923451234567');
      expect(sendSuccess, isTrue);

      final profile = await AuthService.instance.verifyPhoneOtp(
        phone: '+923451234567',
        token: '123456',
      );

      expect(profile, isNotNull);
      expect(profile!.role, equals(UserRole.customer));
      expect(profile.phone, equals('+923451234567'));
      expect(AuthService.instance.isAuthenticated, isTrue);
      expect(AuthService.instance.currentRole, equals(UserRole.customer));
    });

    test('Demo Role Sign In correctly switches roles', () async {
      // Vendor sign in
      var profile = await AuthService.instance.signInDemo(UserRole.vendor);
      expect(profile?.role, equals(UserRole.vendor));
      expect(AuthService.instance.currentRole, equals(UserRole.vendor));

      // Rider sign in
      profile = await AuthService.instance.signInDemo(UserRole.rider);
      expect(profile?.role, equals(UserRole.rider));
      expect(AuthService.instance.currentRole, equals(UserRole.rider));

      // Super Admin sign in
      profile = await AuthService.instance.signInDemo(UserRole.superAdmin);
      expect(profile?.role, equals(UserRole.superAdmin));
      expect(AuthService.instance.currentRole, equals(UserRole.superAdmin));
    });

    test('Sign out clears session and current profile', () async {
      await AuthService.instance.signInDemo(UserRole.customer);
      expect(AuthService.instance.isAuthenticated, isTrue);

      await AuthService.instance.signOut();
      expect(AuthService.instance.isAuthenticated, isFalse);
      expect(AuthService.instance.currentProfile, isNull);
    });

    test('RouteGuard restricts unauthorized paths', () {
      // Customer cannot access admin, vendor, rider paths
      expect(RouteGuard.canAccessRoute(path: AppRoutes.adminOverview, userRole: UserRole.customer), isFalse);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.vendorDashboard, userRole: UserRole.customer), isFalse);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.riderRadar, userRole: UserRole.customer), isFalse);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.customerHome, userRole: UserRole.customer), isTrue);

      // Vendor can access vendor and customer paths, but not admin or rider
      expect(RouteGuard.canAccessRoute(path: AppRoutes.vendorDashboard, userRole: UserRole.vendor), isTrue);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.adminOverview, userRole: UserRole.vendor), isFalse);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.riderRadar, userRole: UserRole.vendor), isFalse);

      // Rider can access rider and customer paths
      expect(RouteGuard.canAccessRoute(path: AppRoutes.riderRadar, userRole: UserRole.rider), isTrue);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.adminOverview, userRole: UserRole.rider), isFalse);

      // Super Admin can access all paths
      expect(RouteGuard.canAccessRoute(path: AppRoutes.adminOverview, userRole: UserRole.superAdmin), isTrue);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.vendorDashboard, userRole: UserRole.superAdmin), isTrue);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.riderRadar, userRole: UserRole.superAdmin), isTrue);
    });
  });
}
