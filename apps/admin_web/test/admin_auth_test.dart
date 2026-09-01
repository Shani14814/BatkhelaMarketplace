import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:admin_web/src/screens/admin_auth_gate.dart';
import 'package:admin_web/src/screens/admin_dashboard_screen.dart';

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

  Widget buildTestApp(Widget home) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: home,
    );
  }

  group('Super Admin Web Authentication Tests', () {
    testWidgets('AdminAuthGate displays Admin Login when unauthenticated', (tester) async {
      await AuthService.instance.signOut();
      await tester.pumpWidget(buildTestApp(const AdminAuthGate()));
      await tester.pumpAndSettle();

      expect(find.text('Super Admin Web Control Center'), findsOneWidget);
      expect(find.text('Sign In to Control Center'), findsOneWidget);
      expect(find.text('Demo Super Admin (1-Click Access)'), findsOneWidget);
    });

    testWidgets('Demo 1-Click Super Admin login navigates to AdminDashboardScreen', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AuthService.instance.signOut();
      await tester.pumpWidget(buildTestApp(const AdminAuthGate()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Demo Super Admin (1-Click Access)'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.text('Super Admin Control'), findsOneWidget);
      expect(AuthService.instance.currentRole, equals(UserRole.superAdmin));
    });

    testWidgets('Non-admin profile cannot access AdminDashboard and shows error', (tester) async {
      await AuthService.instance.signInDemo(UserRole.customer);
      await tester.pumpWidget(buildTestApp(const AdminAuthGate()));
      await tester.pumpAndSettle();

      expect(find.byType(AdminDashboardScreen), findsNothing);
      expect(find.text('Super Admin Web Control Center'), findsOneWidget);
    });
  });
}
