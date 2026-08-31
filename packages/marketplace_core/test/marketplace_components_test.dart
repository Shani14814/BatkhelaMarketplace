import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('Google Stitch Design Tokens & Theme Tests', () {
    test('AppColors contains official Stitch tokens', () {
      expect(AppColors.primary, const Color(0xFF006D77));
      expect(AppColors.indigo, const Color(0xFF5354C7));
      expect(AppColors.coral, const Color(0xFFFE7766));
      expect(AppColors.softCyan, const Color(0xFF9FF0FB));
      expect(AppColors.backgroundLight, const Color(0xFFF3F2FF));
    });

    testWidgets('AppTheme builds valid light and dark ThemeData', (tester) async {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.useMaterial3, isTrue);
      expect(light.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(light.colorScheme.primary, AppColors.primary);
      expect(dark.brightness, Brightness.dark);
    });
  });

  group('MarketplaceHeroBanner Tests', () {
    testWidgets('renders title, tag, subtitle, and fires CTA callback', (tester) async {
      bool ctaTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          MarketplaceHeroBanner(
            title: 'Ramadan Bazaar Special',
            subtitle: 'Get up to 30% off on traditional Shinwari platters',
            tag: 'DEAL OF THE DAY',
            ctaLabel: 'Order Now',
            onCtaTap: () => ctaTapped = true,
          ),
        ),
      );

      expect(find.text('Ramadan Bazaar Special'), findsOneWidget);
      expect(find.text('Get up to 30% off on traditional Shinwari platters'), findsOneWidget);
      expect(find.text('DEAL OF THE DAY'), findsOneWidget);
      expect(find.text('Order Now'), findsOneWidget);

      await tester.tap(find.text('Order Now'));
      await tester.pump();
      expect(ctaTapped, isTrue);
    });
  });

  group('MarketplaceCategoryChip Tests', () {
    testWidgets('renders correctly and handles selected state and tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          MarketplaceCategoryChip(
            label: 'Bakery & Sweets',
            icon: Icons.cake_outlined,
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Bakery & Sweets'), findsOneWidget);
      expect(find.byIcon(Icons.cake_outlined), findsOneWidget);

      await tester.tap(find.text('Bakery & Sweets'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('VendorStoreCard Tests', () {
    testWidgets('renders store information, rating, delivery fee, and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          VendorStoreCard(
            name: 'Khyber Shinwari Tikka',
            category: 'Barbecue • Traditional',
            rating: 4.8,
            reviewCount: 95,
            deliveryTime: '20-30 min',
            deliveryFee: 'Free Delivery',
            badges: const ['Top Rated'],
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Khyber Shinwari Tikka'), findsOneWidget);
      expect(find.text('Barbecue • Traditional'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(95)'), findsOneWidget);
      expect(find.text('20-30 min'), findsOneWidget);
      expect(find.text('Free Delivery'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);

      await tester.tap(find.text('Khyber Shinwari Tikka'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('displays Closed Now overlay when isClosed is true', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const VendorStoreCard(
            name: 'Batkhela Sweets',
            isClosed: true,
          ),
        ),
      );

      expect(find.text('Closed Now'), findsOneWidget);
    });
  });

  group('ProductCatalogCard Tests', () {
    testWidgets('renders name, description, discounted price, and handles Add tap', (tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ProductCatalogCard(
            name: 'Special Chicken Karahi (Full)',
            description: 'Cooked fresh with green chillies and butter',
            price: 1800.0,
            discountPrice: 1530.0,
            isAvailable: true,
            onAdd: () => addTapped = true,
          ),
        ),
      );

      expect(find.text('Special Chicken Karahi (Full)'), findsOneWidget);
      expect(find.text('Cooked fresh with green chillies and butter'), findsOneWidget);
      expect(find.text('PKR 1530'), findsOneWidget);
      expect(find.text('PKR 1800'), findsOneWidget);
      expect(find.text('-15%'), findsOneWidget);
      expect(find.text('ADD'), findsOneWidget);

      await tester.tap(find.text('ADD'));
      await tester.pump();
      expect(addTapped, isTrue);
    });

    testWidgets('displays Sold Out when item is not available', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProductCatalogCard(
            name: 'Mutton Ribs',
            price: 2500.0,
            isAvailable: false,
          ),
        ),
      );

      expect(find.text('Sold Out'), findsOneWidget);
      expect(find.text('ADD'), findsNothing);
    });
  });

  group('MarketplaceStatusBadge Tests', () {
    testWidgets('renders from OrderStatus and custom badge variants', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Column(
            children: [
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.placed),
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.accepted),
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.preparing),
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.readyForPickup),
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.outForDelivery),
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.delivered),
              MarketplaceStatusBadge.fromOrderStatus(OrderStatus.cancelled),
              const MarketplaceStatusBadge(
                label: 'Custom Active',
                variant: BadgeVariant.indigo,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Accepted by Store'), findsOneWidget);
      expect(find.text('Preparing Food/Items'), findsOneWidget);
      expect(find.text('Ready for Rider'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Custom Active'), findsOneWidget);
    });
  });

  group('MarketplaceBottomNav Tests', () {
    testWidgets('renders all destinations, highlights active item, and calls onDestinationSelected', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: MarketplaceBottomNav(
                  currentIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: const [
                    MarketplaceNavDestination(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
                    MarketplaceNavDestination(icon: Icons.search, label: 'Explore'),
                    MarketplaceNavDestination(icon: Icons.receipt_long_outlined, label: 'Orders', badgeCount: 2),
                    MarketplaceNavDestination(icon: Icons.person_outline, label: 'Profile'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Badge count

      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);
    });
  });

  group('KpiCard Tests', () {
    testWidgets('renders metric, label, icon, and positive trend', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          KpiCard(
            label: 'Total Revenue',
            value: 'PKR 84,500',
            icon: Icons.account_balance_wallet_outlined,
            trendText: '+18.4% vs last week',
            isPositiveTrend: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('PKR 84,500'), findsOneWidget);
      expect(find.text('+18.4% vs last week'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

      await tester.tap(find.text('Total Revenue'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('VendorQuickActionButton Tests', () {
    testWidgets('renders label, icon, badge count, and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          VendorQuickActionButton(
            label: 'Incoming Orders',
            icon: Icons.inventory_2_outlined,
            badgeCount: 5,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Incoming Orders'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.text('Incoming Orders'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
