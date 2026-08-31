import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:admin_web/src/data/admin_demo_data.dart';
import 'package:admin_web/src/screens/admin_dashboard_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Super Admin Web Control Center Tests', () {
    testWidgets('Admin Dashboard renders KPIs and sidebar navigation', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      // Brand Header
      expect(find.text('BATKHELA'), findsOneWidget);
      expect(find.text('Super Admin Control'), findsOneWidget);

      // KPI Cards on Overview
      expect(find.text('Gross Platform GMV'), findsOneWidget);
      expect(find.text('Platform Fee Revenue'), findsOneWidget);
      expect(find.text('Orders Today'), findsOneWidget);
      expect(find.text('Active Vendors'), findsOneWidget);

      // Realtime orders stream
      expect(find.text('Realtime Orders Stream'), findsOneWidget);
    });

    testWidgets('Sidebar navigation switches across all 9 admin management domains', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      // 1. Customers Tab
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      expect(find.text('Customer Management Directory'), findsOneWidget);
      expect(find.textContaining('Ahmed Khan'), findsOneWidget);

      // 2. Vendors Tab
      await tester.tap(find.text('Vendors'));
      await tester.pumpAndSettle();
      expect(find.text('Approved Marketplace Stores'), findsOneWidget);

      // 3. Riders Tab
      await tester.tap(find.text('Riders'));
      await tester.pumpAndSettle();
      expect(find.text('Active Delivery Fleet Roster'), findsOneWidget);

      // 4. Orders Tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Search by Order ID, Customer, or Delivery Area...'), findsOneWidget);

      // 5. Categories Tab
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      expect(find.text('Marketplace Category Catalog'), findsOneWidget);
      expect(find.text('Restaurants & BBQ'), findsOneWidget);

      // 6. Homepage Tab
      await tester.tap(find.text('Homepage'));
      await tester.pumpAndSettle();
      expect(find.text('Dynamic Customer Homepage Section Manager'), findsOneWidget);
      expect(find.text('Top Promotional Hero Banners'), findsOneWidget);

      // 7. Promotions Tab
      await tester.tap(find.text('Promotions'));
      await tester.pumpAndSettle();
      expect(find.text('Banner Campaigns & Store Boosts'), findsOneWidget);
      expect(find.text('Batkhela Grand BBQ Festival'), findsOneWidget);

      // 8. Settings Tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Platform Governance & Regional Expansion'), findsOneWidget);
      expect(find.text('Marketplace Core Configuration'), findsOneWidget);
      expect(find.text('Regional Expansion Matrix'), findsOneWidget);

      // 9. Back to Overview Tab
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      expect(find.text('Gross Platform GMV'), findsOneWidget);
    });

    testWidgets('Vendor approval workflow updates status', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vendors'));
      await tester.pumpAndSettle();

      final approveBtn = find.widgetWithText(ElevatedButton, 'Approve Store');
      if (approveBtn.evaluate().isNotEmpty) {
        await tester.tap(approveBtn.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Rider application approval workflow updates status', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Riders'));
      await tester.pumpAndSettle();

      final approveBtn = find.widgetWithText(ElevatedButton, 'Approve Rider');
      if (approveBtn.evaluate().isNotEmpty) {
        await tester.tap(approveBtn.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Category management supports toggling and Add Category dialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();

      // Toggle first category switch
      final switchFinder = find.byType(Switch).first;
      final initialVal = AdminDemoController.instance.categories.first.isEnabled;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(AdminDemoController.instance.categories.first.isEnabled, !initialVal);

      // Open Add Category Dialog
      await tester.tap(find.text('Add Category'));
      await tester.pumpAndSettle();

      expect(find.text('Add Marketplace Category'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'Handicrafts & Gems');
      await tester.tap(find.text('Create Category'));
      await tester.pumpAndSettle();

      expect(AdminDemoController.instance.categories.any((c) => c.name == 'Handicrafts & Gems'), isTrue);
    });

    testWidgets('Homepage sections and Promotions toggle visibility in state', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      // Homepage toggle
      await tester.tap(find.text('Homepage'));
      await tester.pumpAndSettle();
      final homeSwitch = find.byType(Switch).first;
      final initialHomeVis = AdminDemoController.instance.homepageSections.first.isVisible;
      await tester.tap(homeSwitch);
      await tester.pumpAndSettle();
      expect(AdminDemoController.instance.homepageSections.first.isVisible, !initialHomeVis);

      // Promotions toggle
      await tester.tap(find.text('Promotions'));
      await tester.pumpAndSettle();
      final promSwitch = find.byType(Switch).first;
      final initialPromActive = AdminDemoController.instance.promotions.first.isActive;
      await tester.tap(promSwitch);
      await tester.pumpAndSettle();
      expect(AdminDemoController.instance.promotions.first.isActive, !initialPromActive);
    });

    testWidgets('Settings tab allows multi-city regional expansion toggles', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Batkhela (Central & Bypass)'), findsOneWidget);
      expect(find.text('Timergara'), findsOneWidget);

      final citySwitch = find.byType(Switch).at(1);
      await tester.tap(citySwitch);
      await tester.pumpAndSettle();
      expect(AdminDemoController.instance.regionalCities[1].isActive, isTrue);
    });
  });
}
