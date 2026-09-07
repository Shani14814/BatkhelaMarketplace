import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:mobile_app/src/data/rider_demo_data.dart';
import 'package:mobile_app/src/screens/rider/rider_home_screen.dart';
import 'package:mobile_app/src/screens/rider/rider_delivery_detail_screen.dart';
import 'package:mobile_app/src/screens/rider/rider_deliveries_view.dart';
import 'package:mobile_app/src/screens/rider/rider_earnings_view.dart';
import 'package:mobile_app/src/screens/rider/rider_profile_view.dart';
import 'package:mobile_app/src/screens/auth/rider_registration_screen.dart';
import 'package:mobile_app/src/screens/auth/rider_pending_approval_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() async {
    await MarketplaceDataService.instance.riderLocationTracker.stopTracking();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  group('Rider Experience UI Tests', () {
    testWidgets('RiderHomeScreen renders telemetry, KPIs, active delivery, and online switch', (tester) async {
      tester.view.physicalSize = const Size(1200, 3600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RiderHomeScreen()));
      await tester.pumpAndSettle();

      // Title & GPS Telemetry
      expect(find.text('Rider Delivery Radar'), findsOneWidget);
      expect(find.text('Broadcasting Location in Batkhela'), findsOneWidget);

      // KPI Metrics
      expect(find.text("Today's Earnings"), findsOneWidget);
      expect(find.text('Today Completed'), findsOneWidget);

      // Active Delivery
      expect(find.text('Current Assigned Delivery'), findsOneWidget);
      expect(find.text('Trip #DEL-1042'), findsOneWidget);

      // Online / Offline Switch toggle
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(RiderDemoController.instance.isOnline, false);
      expect(find.text('Telemetry Paused'), findsOneWidget);

      // Re-enable
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(RiderDemoController.instance.isOnline, true);
    });

    testWidgets('Rider 4-destination navigation switches views', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RiderHomeScreen()));
      await tester.pumpAndSettle();

      // 1. Switch to Deliveries Tab
      await tester.tap(find.text('Deliveries'));
      await tester.pumpAndSettle();
      expect(find.text('Delivery Assignments'), findsOneWidget);
      expect(find.text('Job Offers'), findsOneWidget);

      // 2. Switch to Earnings Tab
      await tester.tap(find.text('Earnings'));
      await tester.pumpAndSettle();
      expect(find.text('Activity & Earnings'), findsOneWidget);
      expect(find.text("Today's Net Earnings"), findsOneWidget);

      // 3. Switch to Profile Tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Rider Profile & Hub'), findsOneWidget);
      expect(find.text('Kamran Khan'), findsOneWidget);
      expect(find.text('Vehicle & Registration'), findsOneWidget);

      // 4. Switch back to Radar Tab
      await tester.tap(find.text('Radar'));
      await tester.pumpAndSettle();
      expect(find.text('Current Assigned Delivery'), findsOneWidget);
    });

    testWidgets('Rider delivery lifecycle progression transitions smoothly', (tester) async {
      final ctrl = RiderDemoController.instance;

      // Create a test assignment in offered stage
      final testOffer = RiderDeliveryAssignment(
        id: 'DEL-TEST-1',
        orderId: 'ORD-TEST-1',
        orderNumber: 9991,
        storeName: 'Test Burger House',
        pickupAddress: 'Bazaar Road',
        customerArea: 'Main Bypass',
        customerAddress: 'House 5, Bypass',
        itemNames: ['Zinger Burger'],
        cashToCollect: 500.0,
        deliveryFeeEarnings: 100.0,
        distanceKm: 1.5,
        estimatedMinutes: 5,
        stage: DeliveryStage.offered,
        createdAt: DateTime.now(),
      );
      ctrl.assignments.insert(0, testOffer);

      // 1. Accept Assignment
      ctrl.acceptAssignment(testOffer.id);
      expect(testOffer.stage, DeliveryStage.accepted);

      // 2. Arrived at pickup
      ctrl.progressDeliveryStage(testOffer.id);
      expect(testOffer.stage, DeliveryStage.arrivedAtPickup);

      // 3. Picked up
      ctrl.progressDeliveryStage(testOffer.id);
      expect(testOffer.stage, DeliveryStage.pickedUp);

      // 4. On the way
      ctrl.progressDeliveryStage(testOffer.id);
      expect(testOffer.stage, DeliveryStage.onTheWay);

      // 5. Delivered
      ctrl.progressDeliveryStage(testOffer.id);
      expect(testOffer.stage, DeliveryStage.delivered);
    });

    testWidgets('RiderDeliveryDetailScreen renders route preview, checklist, and actions', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sample = RiderDemoController.instance.assignments.first;
      await tester.pumpWidget(buildTestableWidget(RiderDeliveryDetailScreen(delivery: sample)));
      await tester.pumpAndSettle();

      expect(find.text('Delivery #${sample.orderNumber}'), findsOneWidget);
      expect(find.text('Pickup Store'), findsOneWidget);
      expect(find.text(sample.storeName), findsAtLeastNWidgets(1));
      expect(find.text('Customer Drop-off Destination'), findsOneWidget);
      expect(find.text('Package Item Checklist'), findsOneWidget);
      expect(find.text('Cash to Collect'), findsOneWidget);
      expect(find.text('Rider Earnings'), findsOneWidget);
    });

    testWidgets('RiderDeliveriesView displays offers, in-progress, and completed deliveries', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RiderDeliveriesView()));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Assignments'), findsOneWidget);
      expect(find.text('Job Offers'), findsOneWidget);
      expect(find.text('In-Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Switch to in-progress tab
      await tester.tap(find.text('In-Progress'));
      await tester.pumpAndSettle();

      // Switch to completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
    });

    testWidgets('RiderEarningsView displays summaries, breakdown, and history', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RiderEarningsView()));
      await tester.pumpAndSettle();

      expect(find.text('Activity & Earnings'), findsOneWidget);
      expect(find.text("Today's Net Earnings"), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Earnings Structure'), findsOneWidget);
      expect(find.text('Base Delivery Fees'), findsOneWidget);
    });

    testWidgets('RiderProfileView renders partner details and emergency helpline', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RiderProfileView()));
      await tester.pumpAndSettle();

      expect(find.text('Rider Profile & Hub'), findsOneWidget);
      expect(find.text('Kamran Khan'), findsOneWidget);
      expect(find.text('Batkhela Registered Delivery Partner'), findsOneWidget);
      expect(find.text('Vehicle & Registration'), findsOneWidget);
      expect(find.text('Delivery Rating & Reliability'), findsOneWidget);
      expect(find.text('24/7 Rider Emergency Helpline'), findsOneWidget);
    });

    testWidgets('RiderRegistrationScreen collects KYC data and submits application', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RiderRegistrationScreen(initialPhone: '+92 312 9988776')));
      await tester.pumpAndSettle();

      expect(find.text('Rider Partner Registration'), findsOneWidget);
      expect(find.text('1. Personal Information & CNIC'), findsOneWidget);
      expect(find.text('2. Vehicle & License Details'), findsOneWidget);
      expect(find.text('3. Preferred Batkhela Operating Zone'), findsOneWidget);
      expect(find.text('4. Document KYC Verification Proof'), findsOneWidget);

      // Enter details and submit
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Legal Name *'), 'Asif Khan');
      await tester.enterText(find.widgetWithText(TextFormField, 'National CNIC Number *'), '15402-9988112-5');
      await tester.enterText(find.widgetWithText(TextFormField, 'Number Plate *'), 'BK-M-2025-99');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Rider Application'));
      await tester.pumpAndSettle();

      // Verify submission updated controller
      expect(RiderDemoController.instance.profile.name, 'Asif Khan');
      expect(RiderDemoController.instance.profile.cnic, '15402-9988112-5');
      expect(RiderDemoController.instance.isCurrentRiderVerified, isFalse);
    });

    testWidgets('RiderPendingApprovalScreen allows checking status and transitions upon approval', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Reset to unverified
      RiderDemoController.instance.resetToUnverifiedForTesting();

      await tester.pumpWidget(buildTestableWidget(const RiderPendingApprovalScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Application Under Review'), findsOneWidget);
      expect(find.text('Verification Timeline'), findsOneWidget);
      expect(find.text('Check Verification Status'), findsOneWidget);

      // Admin approves rider in controller
      RiderDemoController.instance.approveRider();
      await tester.pumpAndSettle();

      expect(find.text('Rider Partner Approved & Verified!'), findsOneWidget);
      expect(find.text('Open Rider Radar'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Open Rider Radar'));
      await tester.pumpAndSettle();

      expect(RiderDemoController.instance.isCurrentRiderVerified, isTrue);
    });

    testWidgets('RiderDeliveryDetailScreen supports pickup items checklist confirmation', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pickupDelivery = RiderDeliveryAssignment(
        id: 'DEL-PICKUP-TEST',
        orderId: 'ORD-PICKUP-TEST',
        orderNumber: 8871,
        storeName: 'Test BBQ Corner',
        pickupAddress: 'Bypass Road',
        customerArea: 'Main Bazaar',
        customerAddress: 'House 1, Main Bazaar',
        itemNames: ['Chicken Tikka (2 Pcs)', 'Naan (4 Pcs)'],
        cashToCollect: 850.0,
        deliveryFeeEarnings: 120.0,
        distanceKm: 1.2,
        estimatedMinutes: 5,
        stage: DeliveryStage.arrivedAtPickup,
        createdAt: DateTime.now(),
      );
      RiderDemoController.instance.assignments.insert(0, pickupDelivery);

      await tester.pumpWidget(buildTestableWidget(RiderDeliveryDetailScreen(delivery: pickupDelivery)));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Items & Pickup'), findsOneWidget);

      // Tap action to open pickup verification bottom sheet
      await tester.tap(find.text('Confirm Items & Pickup'));
      await tester.pumpAndSettle();

      expect(find.text('Store Pickup Verification'), findsOneWidget);
      expect(find.text('Confirm Items & Start Delivery'), findsOneWidget);

      // Confirm pickup
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Items & Start Delivery'));
      await tester.pumpAndSettle();

      expect(pickupDelivery.stage, DeliveryStage.pickedUp);
      expect(pickupDelivery.isItemsVerifiedAtPickup, isTrue);
    });

    testWidgets('RiderDeliveryDetailScreen supports proof of delivery completion and updates earnings', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final dropoffDelivery = RiderDeliveryAssignment(
        id: 'DEL-DROPOFF-TEST',
        orderId: 'ORD-DROPOFF-TEST',
        orderNumber: 8872,
        storeName: 'Swat Fresh Mart',
        pickupAddress: 'Hospital Road',
        customerArea: 'Civil Colony',
        customerAddress: 'House 7, Civil Colony',
        itemNames: ['MilkPak 1L', 'Brown Bread'],
        cashToCollect: 620.0,
        deliveryFeeEarnings: 110.0,
        distanceKm: 2.0,
        estimatedMinutes: 6,
        stage: DeliveryStage.onTheWay,
        createdAt: DateTime.now(),
      );
      RiderDemoController.instance.assignments.insert(0, dropoffDelivery);

      await tester.pumpWidget(buildTestableWidget(RiderDeliveryDetailScreen(delivery: dropoffDelivery)));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Delivery & Collect Cash'), findsOneWidget);

      // Tap action to open proof of delivery sheet
      await tester.tap(find.text('Confirm Delivery & Collect Cash'));
      await tester.pumpAndSettle();

      expect(find.text('Proof of Delivery & Handover'), findsOneWidget);
      expect(find.text('Cash to Collect (COD)'), findsOneWidget);
      expect(find.text('Confirm Handover & Complete Trip'), findsOneWidget);

      // Confirm delivery
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Handover & Complete Trip'));
      await tester.pumpAndSettle();

      expect(dropoffDelivery.stage, DeliveryStage.delivered);
      expect(dropoffDelivery.proofType, isNotNull);
    });
  });
}
