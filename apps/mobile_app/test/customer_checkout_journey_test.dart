import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';
import 'package:mobile_app/src/screens/customer/cart_sheet.dart';
import 'package:mobile_app/src/screens/customer/checkout_screen.dart';
import 'package:mobile_app/src/screens/customer/order_confirmation_screen.dart';
import 'package:mobile_app/src/screens/customer/product_detail_sheet.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthService.instance.initialize(
      repository: DemoAuthRepository(),
      isDemoMode: true,
    );
    CartController.instance.clear();
  });

  Widget buildTestApp(Widget home) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: home),
    );
  }

  group('Customer Checkout Journey End-to-End Tests', () {
    final testProduct = Product(
      id: 'prod_test_1',
      vendorId: 'vendor_1',
      name: 'Shinwari Lamb Karahi',
      category: 'Food & Dining',
      price: 1500.0,
      discountPrice: 1400.0,
      isAvailable: true,
      imageUrl: '',
      createdAt: DateTime.now(),
    );

    testWidgets('ProductDetailSheet allows customizing, updating quantity, and adding to cart', (tester) async {
      await tester.pumpWidget(buildTestApp(
        ProductDetailSheet(
          product: testProduct,
          vendorId: 'vendor_1',
          vendorName: 'Khyber Shinwari',
        ),
      ));

      expect(find.text('Shinwari Lamb Karahi'), findsOneWidget);
      expect(find.text('Khyber Shinwari'), findsOneWidget);
      expect(find.text('PKR 1400'), findsWidgets);

      // Increase quantity to 2
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('PKR 2800'), findsOneWidget);

      // Add to cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(CartController.instance.totalItemCount, 2);
      expect(CartController.instance.subtotal, 2800.0);
    });

    testWidgets('CartSheet displays bill breakdown and navigates to Checkout', (tester) async {
      CartController.instance.addItem(
        testProduct,
        vendorId: 'vendor_1',
        vendorName: 'Khyber Shinwari',
        quantity: 1,
      );

      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => CartSheet.show(context),
              child: const Text('Open Cart'),
            );
          },
        ),
      ));

      await tester.tap(find.text('Open Cart'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Your Order Cart'), findsOneWidget);
      expect(find.text('Shinwari Lamb Karahi'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('CheckoutScreen renders order items, payment selection, and places order', (tester) async {
      await AuthService.instance.signInDemo(UserRole.customer);

      CartController.instance.addItem(
        testProduct,
        vendorId: 'vendor_1',
        vendorName: 'Khyber Shinwari',
        quantity: 1,
      );

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CheckoutScreen(),
      ));

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Delivery Location'), findsOneWidget);
      expect(find.text('Select Payment Method'), findsOneWidget);
      expect(find.textContaining('Cash on Delivery (COD)'), findsOneWidget);

      // Tap Place Order Button
      await tester.tap(find.textContaining('Place Order'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(OrderConfirmationScreen), findsOneWidget);
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(CartController.instance.isEmpty, isTrue);
    });
  });
}
