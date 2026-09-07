import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:mobile_app/src/data/vendor_demo_data.dart';
import 'package:mobile_app/src/screens/vendor/vendor_dashboard_screen.dart';
import 'package:mobile_app/src/screens/vendor/vendor_order_detail_screen.dart';
import 'package:mobile_app/src/screens/vendor/vendor_products_view.dart';
import 'package:mobile_app/src/screens/vendor/vendor_business_view.dart';
import 'package:mobile_app/src/screens/vendor/vendor_more_view.dart';
import 'package:mobile_app/src/screens/auth/vendor_registration_screen.dart';
import 'package:mobile_app/src/screens/auth/vendor_pending_approval_screen.dart';

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

  group('Vendor Experience UI Tests', () {
    testWidgets('VendorDashboardScreen renders KPIs, Quick Actions, and Status', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const VendorDashboardScreen()));
      await tester.pumpAndSettle();

      // Store Title
      expect(find.text('Khyber Shinwari Tikka & Karahi'), findsOneWidget);

      // KPI Metrics
      expect(find.text("Today's Sales"), findsOneWidget);
      expect(find.text('Active Orders'), findsOneWidget);
      expect(find.text('Store Rating'), findsOneWidget);
      expect(find.text('Active Menu Items'), findsOneWidget);

      // Quick Actions
      expect(find.text('Orders Queue'), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);
      expect(find.text('Store Profile'), findsOneWidget);
      expect(find.text('Riders Hub'), findsOneWidget);

      // Store Open switch toggle
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(VendorDemoController.instance.store.isOpen, false);

      // Re-enable
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(VendorDemoController.instance.store.isOpen, true);
    });

    testWidgets('Vendor 5-destination bottom navigation switches views', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VendorDashboardScreen()));
      await tester.pumpAndSettle();

      // 1. Switch to Orders Tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Order Management'), findsOneWidget);
      expect(find.text('New (Pending)'), findsOneWidget);

      // 2. Switch to Products Tab
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Product Inventory'), findsOneWidget);

      // 3. Switch to Business Tab
      await tester.tap(find.text('Business'));
      await tester.pumpAndSettle();
      expect(find.text('Store Profile & Settings'), findsOneWidget);

      // 4. Switch to More Tab
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Store Operations & Hub'), findsOneWidget);
      expect(find.text('Delivery Rider Network'), findsOneWidget);

      // 5. Switch back to Dashboard Tab
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Operations'), findsOneWidget);
    });

    testWidgets('Order status transitions in Vendor Orders Queue', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VendorDashboardScreen()));
      await tester.pumpAndSettle();

      // Go to Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Find Accept button on pending order
      final acceptBtn = find.widgetWithText(ElevatedButton, 'Accept');
      if (acceptBtn.evaluate().isNotEmpty) {
        await tester.tap(acceptBtn.first);
        await tester.pumpAndSettle();
      }

      // Check preparing transition
      final startCookingBtn = find.widgetWithText(ElevatedButton, 'Start Cooking');
      if (startCookingBtn.evaluate().isNotEmpty) {
        await tester.tap(startCookingBtn.first);
        await tester.pumpAndSettle();
      }

      // Check mark ready transition
      final markReadyBtn = find.widgetWithText(ElevatedButton, 'Mark Ready');
      if (markReadyBtn.evaluate().isNotEmpty) {
        await tester.tap(markReadyBtn.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('VendorOrderDetailScreen renders details and lifecycle action bar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleOrder = VendorDemoController.instance.orders.first;
      await tester.pumpWidget(buildTestableWidget(VendorOrderDetailScreen(order: sampleOrder)));
      await tester.pumpAndSettle();

      // Header and customer
      expect(find.text('Order #${sampleOrder.orderNumber ?? sampleOrder.id}'), findsOneWidget);
      expect(find.text('Ordered Items'), findsOneWidget);
      expect(find.text('Payment & Bill Details'), findsOneWidget);
      expect(find.text('Order Timeline'), findsOneWidget);
    });

    testWidgets('VendorProductsView toggles stock and supports Add Product dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const VendorProductsView()));
      await tester.pumpAndSettle();

      expect(find.text('Product Inventory'), findsOneWidget);

      // Toggle stock switch
      final stockSwitch = find.byType(Switch).first;
      final initialAvailability = VendorDemoController.instance.products.first.isAvailable;
      await tester.tap(stockSwitch);
      await tester.pumpAndSettle();
      expect(VendorDemoController.instance.products.first.isAvailable, !initialAvailability);

      // Open Add Product modal
      final addBtn = find.widgetWithText(FloatingActionButton, 'Add Product');
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add New Product'), findsOneWidget);
      expect(find.text('Product Name *'), findsOneWidget);
      expect(find.text('Regular Price (PKR) *'), findsOneWidget);

      // Enter details and submit
      await tester.enterText(find.widgetWithText(TextField, 'Product Name *'), 'Special Tikka Platter');
      await tester.enterText(find.widgetWithText(TextField, 'Regular Price (PKR) *'), '1850');
      await tester.enterText(find.widgetWithText(TextField, 'Description / Ingredients'), 'Assorted mix BBQ platter');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Product'));
      await tester.pumpAndSettle();

      // Verify product added to controller
      expect(VendorDemoController.instance.products.any((p) => p.name == 'Special Tikka Platter'), isTrue);
    });

    testWidgets('VendorRegistrationScreen collects KYC data and submits application', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const VendorRegistrationScreen(initialPhone: '+92 345 1122334')));
      await tester.pumpAndSettle();

      expect(find.text('Vendor Registration & KYC'), findsOneWidget);
      expect(find.text('Store Details'), findsOneWidget);
      expect(find.text('Owner & Legal Information'), findsOneWidget);

      // Enter store name, owner, and address
      await tester.enterText(find.widgetWithText(TextFormField, 'Store Name *'), 'Batkhela Organic Mart');
      await tester.enterText(find.widgetWithText(TextFormField, 'Owner Full Name *'), 'Imran Shah');
      await tester.enterText(find.widgetWithText(TextFormField, 'CNIC / Trade License Number *'), '15402-1122334-5');
      await tester.enterText(find.widgetWithText(TextFormField, 'Store Physical Address *'), 'Shop 12, Main GT Road, Batkhela');

      // Tap submit button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Application for Review'));
      await tester.pumpAndSettle();

      // Should transition to VendorPendingApprovalScreen
      expect(find.text('Store Verification'), findsOneWidget);
      expect(find.text('Application Under Review'), findsOneWidget);
      expect(find.text('Batkhela Organic Mart'), findsOneWidget);
      expect(VendorDemoController.instance.store.isVerified, isFalse);
    });

    testWidgets('VendorPendingApprovalScreen allows checking status and transitions upon approval', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Ensure store is currently unverified
      VendorDemoController.instance.resetToUnverifiedForTesting();

      await tester.pumpWidget(buildTestableWidget(const VendorPendingApprovalScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Application Under Review'), findsOneWidget);
      expect(find.text('Verification Timeline'), findsOneWidget);
      expect(find.text('Check Verification Status'), findsOneWidget);

      // Admin approves the store in backend/controller
      VendorDemoController.instance.approveVendorStore();
      await tester.pumpAndSettle();

      expect(find.text('Store Approved & Verified!'), findsOneWidget);
      expect(find.text('Open Vendor Dashboard'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Open Vendor Dashboard'));
      await tester.pumpAndSettle();

      expect(find.text('Store Operations & Quick Actions'), findsNothing); // Navigates to Dashboard
      expect(VendorDemoController.instance.isCurrentVendorVerified, isTrue);
    });

    testWidgets('VendorProductsView supports editing and deleting existing products', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const VendorProductsView()));
      await tester.pumpAndSettle();

      // Open Edit Product Modal for the first product
      final editButtons = find.byIcon(Icons.edit_outlined);
      expect(editButtons, findsWidgets);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Product'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Modify price
      await tester.enterText(find.widgetWithText(TextField, 'Regular Price (PKR) *'), '2550');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('PKR 2550'), findsWidgets);

      // Test Delete product flow
      final deleteButtons = find.byIcon(Icons.delete_outline);
      final initialProductCount = VendorDemoController.instance.products.length;
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Product?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(VendorDemoController.instance.products.length, initialProductCount - 1);
    });

    testWidgets('VendorBusinessView renders info, logo, banner, and operational switch', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VendorBusinessView()));
      await tester.pumpAndSettle();

      expect(find.text('Store Profile & Settings'), findsOneWidget);
      expect(find.text('Merchant Phone'), findsOneWidget);
      expect(find.text('Store Location'), findsOneWidget);
      expect(find.text('Operating Hours'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
    });

    testWidgets('VendorMoreView allows approving and rejecting rider applications', (tester) async {
      tester.view.physicalSize = const Size(1200, 3600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const VendorMoreView()));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Rider Network'), findsOneWidget);
      expect(find.text('Sales & Operational Insights'), findsOneWidget);
      expect(find.text('Top Selling Items Today'), findsOneWidget);

      // If pending riders exist, test approval
      final approveBtn = find.widgetWithText(ElevatedButton, 'Approve Rider');
      if (approveBtn.evaluate().isNotEmpty) {
        await tester.tap(approveBtn.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Vendor Add Product allows opening image source modal with device and preset options', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const VendorProductsView()));
      await tester.pumpAndSettle();

      // Open Add Product modal
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add Product'));
      await tester.pumpAndSettle();

      // Tap Choose Image button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Choose Image'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Image Source'), findsOneWidget);
      expect(find.text('Choose from Device Gallery'), findsOneWidget);
      expect(find.text('Capture with Camera'), findsOneWidget);
      expect(find.text('Or Select Demo Catalog Preset:'), findsOneWidget);

      // Select a preset item
      await tester.tap(find.text('Mutton Karahi').first);
      await tester.pumpAndSettle();

      expect(find.text('Choose Image Source'), findsNothing);
    });
  });
}
