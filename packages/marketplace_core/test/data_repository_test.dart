import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_core/marketplace_core.dart';

void main() {
  setUp(() {
    MarketplaceDataService.instance.initialize(isDemoMode: true);
  });

  group('Marketplace Repository & Data Hub Tests', () {
    test('MarketplaceDataService initializes all 8 repositories in Demo Mode', () {
      final hub = MarketplaceDataService.instance;
      expect(hub.isDemoMode, isTrue);
      expect(hub.customerRepo, isA<DemoCustomerRepository>());
      expect(hub.vendorRepo, isA<DemoVendorRepository>());
      expect(hub.productRepo, isA<DemoProductRepository>());
      expect(hub.orderRepo, isA<DemoOrderRepository>());
      expect(hub.riderRepo, isA<DemoRiderRepository>());
      expect(hub.deliveryRepo, isA<DemoDeliveryRepository>());
      expect(hub.categoryRepo, isA<DemoCategoryRepository>());
      expect(hub.adminRepo, isA<DemoAdminRepository>());
    });

    test('CustomerRepository retrieves categories and verified vendors', () async {
      final customerRepo = MarketplaceDataService.instance.customerRepo;
      final categories = await customerRepo.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.first.name, 'Food & Dining');

      final vendors = await customerRepo.getVendors();
      expect(vendors, isNotEmpty);
      expect(vendors.any((v) => v.storeName.contains('Khyber Shinwari')), isTrue);
    });

    test('CustomerRepository search filter finds matching stores', () async {
      final customerRepo = MarketplaceDataService.instance.customerRepo;
      final searchResults = await customerRepo.getVendors(searchQuery: 'Shinwari');
      expect(searchResults.length, 1);
      expect(searchResults.first.storeName, 'Khyber Shinwari Tikka & Karahi');
    });

    test('CustomerRepository customer addresses management', () async {
      final customerRepo = MarketplaceDataService.instance.customerRepo;
      final addresses = await customerRepo.getCustomerAddresses('demo-user-default');
      expect(addresses, isNotEmpty);

      final newAddr = CustomerAddress(
        id: 'addr-new',
        userId: 'demo-user-default',
        title: 'Work',
        fullAddress: 'Batkhela Bazaar Shop 12',
        city: 'Batkhela',
        createdAt: DateTime.now(),
      );
      await customerRepo.addCustomerAddress(newAddr);
      final updatedAddresses = await customerRepo.getCustomerAddresses('demo-user-default');
      expect(updatedAddresses.any((a) => a.id == 'addr-new'), isTrue);
    });

    test('Order trusted total calculation and place order verification', () async {
      final orderRepo = MarketplaceDataService.instance.orderRepo;
      const orderItems = [
        OrderItem(
          id: 'it-1',
          orderId: '',
          productName: 'Mutton Karahi',
          unitPrice: 2000.0,
          quantity: 2,
          totalPrice: 4000.0,
        ),
      ];

      final untrustedOrder = MarketplaceOrder(
        id: '',
        customerId: 'cust-1',
        vendorId: 'store-1',
        subtotal: 10.0, // Client tried to tamper subtotal
        deliveryFee: 150.0,
        platformFee: 30.0,
        totalAmount: 190.0, // Client tried to tamper total
        status: OrderStatus.placed,
        deliveryAddress: 'Main Road Batkhela',
        items: orderItems,
        createdAt: DateTime.now(),
      );

      final placedOrder = await orderRepo.placeOrder(untrustedOrder);
      // Trusted calculation on server/repository: 4000 subtotal + 150 delivery + 30 platform = 4180
      expect(placedOrder.subtotal, 4000.0);
      expect(placedOrder.totalAmount, 4180.0);
      expect(placedOrder.status, OrderStatus.placed);
    });

    test('VendorRepository updates store open/closed status', () async {
      final vendorRepo = MarketplaceDataService.instance.vendorRepo;
      final vendor = await vendorRepo.updateStoreStatus('store-1', isOpen: false);
      expect(vendor.isOpen, isFalse);

      final reOpened = await vendorRepo.updateStoreStatus('store-1', isOpen: true);
      expect(reOpened.isOpen, isTrue);
    });

    test('ProductRepository toggles availability and CRUD operations', () async {
      final productRepo = MarketplaceDataService.instance.productRepo;
      final products = await productRepo.getProductsByVendor('store-1');
      expect(products, isNotEmpty);

      final toggled = await productRepo.toggleProductAvailability(products.first.id, false);
      expect(toggled.isAvailable, isFalse);
    });

    test('RiderRepository telemetry location and online status', () async {
      final riderRepo = MarketplaceDataService.instance.riderRepo;
      await riderRepo.updateOnlineStatus('rider-prof-1', true);
      await riderRepo.updateTelemetryLocation(
        'rider-prof-1',
        latitude: 34.6190,
        longitude: 71.9730,
        heading: 90.0,
      );

      final profile = await riderRepo.getRiderProfile('rider-prof-1');
      expect(profile, isNotNull);
      expect(profile!.fullName, 'Salman Khan');

      final earnings = await riderRepo.getRiderEarnings('rider-prof-1');
      expect(earnings, isNotEmpty);
      final total = await riderRepo.getRiderTotalEarnings('rider-prof-1');
      expect(total, greaterThan(0));
    });

    test('DeliveryRepository lifecycle transitions', () async {
      final deliveryRepo = MarketplaceDataService.instance.deliveryRepo;
      final available = await deliveryRepo.getAvailableDeliveries();
      expect(available, isNotEmpty);

      final accepted = await deliveryRepo.acceptDelivery(available.first.id, 'rider-prof-1');
      expect(accepted.status, DeliveryStatus.assigned);

      final inTransit = await deliveryRepo.updateDeliveryStatus(accepted.id, DeliveryStatus.pickedUp);
      expect(inTransit.status, DeliveryStatus.pickedUp);
      expect(inTransit.pickupTime, isNotNull);

      final delivered = await deliveryRepo.updateDeliveryStatus(accepted.id, DeliveryStatus.delivered);
      expect(delivered.status, DeliveryStatus.delivered);
      expect(delivered.deliveredTime, isNotNull);
    });

    test('AdminRepository approvals, city toggles, and promotions', () async {
      final adminRepo = MarketplaceDataService.instance.adminRepo;
      final kpis = await adminRepo.getPlatformKpis();
      expect(kpis['totalGmv'], greaterThan(0));

      final cities = await adminRepo.getServiceCities();
      expect(cities.any((c) => c.name == 'Batkhela'), isTrue);

      final toggledCity = await adminRepo.toggleCityActive('city-3', true);
      expect(toggledCity.isActive, isTrue);

      final promos = await adminRepo.getPromotions();
      expect(promos, isNotEmpty);
      expect(promos.first.code, 'BATKHELAFREE');
    });

    test('New Domain Models JSON serialization and deserialization', () {
      const cat = MarketplaceCategory(
        id: 'c1',
        slug: 'food',
        name: 'Food',
        nameUrdu: 'کھانا',
        icon: 'fastfood',
        displayOrder: 1,
        isActive: true,
      );
      final catJson = cat.toJson();
      final fromCat = MarketplaceCategory.fromJson(catJson);
      expect(fromCat.id, 'c1');
      expect(fromCat.nameUrdu, 'کھانا');

      final promo = Promotion(
        id: 'p1',
        code: 'TEST10',
        title: 'Test 10%',
        discountPercent: 10.0,
        minOrderAmount: 200.0,
        isActive: true,
        validUntil: DateTime(2026, 12, 31),
      );
      final promoJson = promo.toJson();
      final fromPromo = Promotion.fromJson(promoJson);
      expect(fromPromo.code, 'TEST10');
      expect(fromPromo.discountPercent, 10.0);

      const city = ServiceCity(
        id: 'sc1',
        name: 'Batkhela',
        province: 'KP',
        isActive: true,
        deliveryRadiusKm: 15.0,
      );
      final cityJson = city.toJson();
      final fromCity = ServiceCity.fromJson(cityJson);
      expect(fromCity.name, 'Batkhela');
      expect(fromCity.deliveryRadiusKm, 15.0);
    });
  });
}
