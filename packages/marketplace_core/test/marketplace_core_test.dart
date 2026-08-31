import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Marketplace Core Models Test', () {
    test('UserProfile JSON serialization and deserialization', () {
      final user = UserProfile(
        id: 'usr-123',
        phone: '+923450000000',
        fullName: 'Test Vendor',
        role: UserRole.vendor,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = user.toJson();
      expect(json['id'], 'usr-123');
      expect(json['role'], 'vendor');

      final reconstructed = UserProfile.fromJson(json);
      expect(reconstructed.id, user.id);
      expect(reconstructed.role, UserRole.vendor);
      expect(reconstructed.fullName, 'Test Vendor');
    });

    test('MarketplaceOrder effective calculation and status', () {
      final order = MarketplaceOrder(
        id: 'ord-99',
        customerId: 'cust-1',
        vendorId: 'vend-1',
        subtotal: 1000.0,
        deliveryFee: 100.0,
        platformFee: 50.0,
        totalAmount: 1150.0,
        status: OrderStatus.outForDelivery,
        deliveryAddress: 'Batkhela Main Bazaar',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(order.status.displayName, 'Out for Delivery');
      expect(order.status.toDbString(), 'out_for_delivery');
    });

    test('Product effective price with discount', () {
      final productWithDiscount = Product(
        id: 'p-1',
        vendorId: 'v-1',
        name: 'Shinwari Mutton Karahi',
        price: 1500.0,
        discountPrice: 1350.0,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(productWithDiscount.effectivePrice, 1350.0);

      final productRegular = Product(
        id: 'p-2',
        vendorId: 'v-1',
        name: 'Naan',
        price: 40.0,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(productRegular.effectivePrice, 40.0);
    });

    test('RouteGuard role access control', () {
      expect(RouteGuard.canAccessRoute(path: AppRoutes.adminOverview, userRole: UserRole.customer), isFalse);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.adminOverview, userRole: UserRole.admin), isTrue);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.vendorDashboard, userRole: UserRole.vendor), isTrue);
      expect(RouteGuard.canAccessRoute(path: AppRoutes.riderRadar, userRole: UserRole.rider), isTrue);
    });

    test('Localization foundation RTL check', () {
      expect(AppLocalizationFoundation.isRtl(const Locale('en', 'US')), isFalse);
      expect(AppLocalizationFoundation.isRtl(const Locale('ur', 'PK')), isTrue);
      expect(AppLocalizationFoundation.textDirectionFor(const Locale('ur', 'PK')), TextDirection.rtl);
    });
  });
}
