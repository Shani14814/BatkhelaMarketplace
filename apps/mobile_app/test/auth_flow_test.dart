import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:mobile_app/src/screens/auth/auth_gate.dart';
import 'package:mobile_app/src/screens/auth/phone_login_screen.dart';
import 'package:mobile_app/src/screens/auth/otp_verification_screen.dart';
import 'package:mobile_app/src/screens/auth/customer_profile_setup_screen.dart';
import 'package:mobile_app/src/screens/customer/customer_home_screen.dart';
import 'package:mobile_app/src/screens/vendor/vendor_dashboard_screen.dart';
import 'package:mobile_app/src/screens/rider/rider_home_screen.dart';
import 'package:mobile_app/src/screens/role_selector_screen.dart';
import 'package:mobile_app/src/data/vendor_demo_data.dart';
import 'package:mobile_app/src/data/rider_demo_data.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthService.instance.initialize(
      repository: DemoAuthRepository(),
      isDemoMode: true,
    );
  });

  tearDown(() async {
    await MarketplaceDataService.instance.riderLocationTracker.stopTracking();
  });

  Widget buildTestApp(Widget home) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: home,
    );
  }

  group('Mobile Authentication Flow Widget Tests', () {
    testWidgets('AuthGate shows PhoneLoginScreen when unauthenticated', (tester) async {
      await AuthService.instance.signOut();
      await tester.pumpWidget(buildTestApp(const AuthGate()));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneLoginScreen), findsOneWidget);
      expect(find.text('BATKHELA MARKETPLACE'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
    });

    testWidgets('PhoneLoginScreen navigates to OtpVerificationScreen on valid phone submission', (tester) async {
      await AuthService.instance.signOut();
      await tester.pumpWidget(buildTestApp(const PhoneLoginScreen()));

      await tester.enterText(find.byType(TextField), '3451234567');
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.text('Verification Code'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen logs in and navigates new customer to CustomerProfileSetupScreen', (tester) async {
      await AuthService.instance.signOut();
      await tester.pumpWidget(buildTestApp(
        const OtpVerificationScreen(phoneNumber: '+923451234567'),
      ));

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify & Proceed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CustomerProfileSetupScreen), findsOneWidget);
      expect(AuthService.instance.isAuthenticated, isTrue);

      // Fill in customer profile details and proceed to CustomerHomeScreen
      await tester.enterText(find.byType(TextFormField).first, 'Farhan Khan');
      await tester.tap(find.text('Save & Start Shopping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CustomerHomeScreen), findsOneWidget);
    });

    testWidgets('AuthGate routes to VendorDashboardScreen when authenticated as verified Vendor', (tester) async {
      VendorDemoController.instance.approveVendorStore();
      await AuthService.instance.signInDemo(UserRole.vendor);
      await tester.pumpWidget(buildTestApp(const AuthGate()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(VendorDashboardScreen), findsOneWidget);
    });

    testWidgets('AuthGate routes to VendorPendingApprovalScreen when authenticated as unverified Vendor', (tester) async {
      VendorDemoController.instance.resetToUnverifiedForTesting();
      await AuthService.instance.signInDemo(UserRole.vendor);
      await tester.pumpWidget(buildTestApp(const AuthGate()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Application Under Review'), findsOneWidget);

      // Clean up for subsequent tests
      VendorDemoController.instance.approveVendorStore();
    });

    testWidgets('AuthGate routes to RiderHomeScreen when authenticated as verified Rider', (tester) async {
      RiderDemoController.instance.approveRider();
      await AuthService.instance.signInDemo(UserRole.rider);
      await tester.pumpWidget(buildTestApp(const AuthGate()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RiderHomeScreen), findsOneWidget);
    });

    testWidgets('AuthGate routes to RiderPendingApprovalScreen when authenticated as unverified Rider', (tester) async {
      RiderDemoController.instance.resetToUnverifiedForTesting();
      await AuthService.instance.signInDemo(UserRole.rider);
      await tester.pumpWidget(buildTestApp(const AuthGate()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Application Under Review'), findsOneWidget);

      // Clean up
      RiderDemoController.instance.approveRider();
    });

    testWidgets('PhoneLoginScreen allows switching to Demo RoleSelectorScreen', (tester) async {
      await AuthService.instance.signOut();
      await tester.pumpWidget(buildTestApp(const PhoneLoginScreen()));

      await tester.tap(find.text('Switch to Demo Testing Mode (Role Selector)'));
      await tester.pumpAndSettle();

      expect(find.byType(RoleSelectorScreen), findsOneWidget);
    });
  });
}
