import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:mobile_app/src/screens/customer/customer_home_screen.dart';
import 'package:mobile_app/src/screens/customer/store_detail_screen.dart';
import 'package:mobile_app/src/screens/role_selector_screen.dart';
import 'package:mobile_app/src/data/customer_demo_data.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestApp(Widget home) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: home,
    );
  }

  group('Customer Marketplace Journey Widget Tests', () {
    testWidgets('RoleSelectorScreen renders customer role and navigates to CustomerHomeScreen', (tester) async {
      await tester.pumpWidget(buildTestApp(const RoleSelectorScreen()));

      expect(find.text('BATKHELA MARKETPLACE'), findsOneWidget);
      expect(find.text('Customer Experience'), findsOneWidget);

      await tester.tap(find.text('Customer Experience'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerHomeScreen), findsOneWidget);
    });

    testWidgets('CustomerHomeScreen renders header, banner, categories, and stores', (tester) async {
      await tester.pumpWidget(buildTestApp(const CustomerHomeScreen()));

      expect(find.text('DELIVERING TO'), findsOneWidget);
      expect(find.text(CustomerDemoData.activeDeliveryAddress), findsOneWidget);
      expect(find.text('Batkhela Local Express'), findsOneWidget);
      expect(find.text('Popular Stores in Batkhela'), findsOneWidget);
      expect(find.text('Khyber Shinwari Tikka & Karahi'), findsOneWidget);
    });

    testWidgets('CustomerHomeScreen bottom navigation switches tabs cleanly', (tester) async {
      await tester.pumpWidget(buildTestApp(const CustomerHomeScreen()));

      // 1. Explore Tab
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(find.text('Explore Batkhela Businesses'), findsOneWidget);

      // 2. Search Tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search anything in Batkhela'), findsOneWidget);

      // 3. Orders Tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Your Orders'), findsOneWidget);
      expect(find.text('Order #1042'), findsOneWidget);

      // 4. Profile Tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Customer Account'), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
    });

    testWidgets('Search tab searches stores and products dynamically', (tester) async {
      await tester.pumpWidget(buildTestApp(const CustomerHomeScreen()));

      // Go to search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Enter query 'Shinwari'
      await tester.enterText(find.byType(TextField), 'Shinwari');
      await tester.pumpAndSettle();

      expect(find.text('Stores (1)'), findsOneWidget);
      expect(find.text('Khyber Shinwari Tikka & Karahi'), findsOneWidget);
      expect(find.text('Shinwari Mutton Karahi (Full KG)'), findsOneWidget);
    });

    testWidgets('StoreDetailScreen renders store details and handles adding to cart', (tester) async {
      final store = CustomerDemoData.stores.first;

      await tester.pumpWidget(buildTestApp(StoreDetailScreen(store: store)));

      expect(find.text('Khyber Shinwari Tikka & Karahi'), findsOneWidget);
      expect(find.text('Shinwari Mutton Karahi (Full KG)'), findsOneWidget);
      expect(find.text('Open Now'), findsOneWidget);

      // Tap ADD button on first product
      await tester.tap(find.text('ADD').first);
      await tester.pumpAndSettle();

      // Bottom cart bar should appear
      expect(find.text('1 Items in Cart'), findsOneWidget);
      expect(find.text('View Cart'), findsOneWidget);

      // Open View Cart modal
      await tester.tap(find.text('View Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Your Order Cart'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });
  });
}
