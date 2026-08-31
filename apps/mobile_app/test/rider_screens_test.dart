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

  group('Rider Experience UI Tests', () {
    testWidgets('RiderHomeScreen renders telemetry, KPIs, active delivery, and online switch', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RiderHomeScreen()));
      await tester.pumpAndSettle();

      // Title & GPS Telemetry
      expect(find.text('Rider Delivery Radar'), findsOneWidget);
      expect(find.text('Batkhela GPS Node Broadcasting'), findsOneWidget);

      // KPI Metrics
      expect(find.text("Today's Earnings"), findsOneWidget);
      expect(find.text('Today Completed'), findsOneWidget);

      // Active Delivery
      expect(find.text('Current Assigned Delivery'), findsOneWidget);
      expect(find.text('Delivery #1042'), findsOneWidget);

      // Online / Offline Switch toggle
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(RiderDemoController.instance.isOnline, false);
      expect(find.text('GPS Broadcasting Paused'), findsOneWidget);

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
  });
}
