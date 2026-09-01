import 'dart:async';
import '../../models/vendor.dart';
import '../../models/order.dart';
import '../vendor_repository.dart';

class DemoVendorRepository implements VendorRepository {
  final _vendorOrdersController = StreamController<List<MarketplaceOrder>>.broadcast();
  final _vendorProfileController = StreamController<Vendor?>.broadcast();

  final Map<String, Vendor> _vendors = {
    'store-1': Vendor(
      id: 'store-1',
      storeName: 'Khyber Shinwari Tikka & Karahi',
      slug: 'khyber-shinwari',
      description: 'Authentic Shinwari Karahi & BBQ',
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&q=80',
      address: 'Main Bazar, GT Road, Batkhela',
      latitude: 34.6185,
      longitude: 71.9723,
      phone: '+92 345 9001122',
      commissionRate: 10.0,
      isOpen: true,
      isVerified: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  };

  final List<MarketplaceOrder> _orders = [
    MarketplaceOrder(
      id: 'ord-v-101',
      orderNumber: 1042,
      customerId: 'demo-cust-1',
      vendorId: 'store-1',
      subtotal: 2650.0,
      deliveryFee: 120.0,
      platformFee: 30.0,
      totalAmount: 2800.0,
      status: OrderStatus.placed,
      paymentMethod: 'cash_on_delivery',
      paymentStatus: 'pending',
      deliveryAddress: 'Mohallah Zargarano, Batkhela',
      items: const [
        OrderItem(
          id: 'item-1',
          orderId: 'ord-v-101',
          productName: 'Special Shinwari Mutton Karahi (1 KG)',
          unitPrice: 2250.0,
          quantity: 1,
          totalPrice: 2250.0,
        ),
        OrderItem(
          id: 'item-2',
          orderId: 'ord-v-101',
          productName: 'Peshawari Chapli Kabab (Plate)',
          unitPrice: 400.0,
          quantity: 1,
          totalPrice: 400.0,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    MarketplaceOrder(
      id: 'ord-v-102',
      orderNumber: 1041,
      customerId: 'demo-cust-2',
      vendorId: 'store-1',
      subtotal: 1800.0,
      deliveryFee: 100.0,
      platformFee: 25.0,
      totalAmount: 1925.0,
      status: OrderStatus.preparing,
      paymentMethod: 'cash_on_delivery',
      paymentStatus: 'pending',
      deliveryAddress: 'Near Degree College, Batkhela',
      items: const [
        OrderItem(
          id: 'item-3',
          orderId: 'ord-v-102',
          productName: 'Chicken Karahi Special (Full)',
          unitPrice: 1400.0,
          quantity: 1,
          totalPrice: 1400.0,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  @override
  Future<Vendor?> getVendorProfile(String vendorId) async {
    return _vendors[vendorId] ?? _vendors['store-1'];
  }

  @override
  Stream<Vendor?> streamVendorProfile(String vendorId) async* {
    yield await getVendorProfile(vendorId);
    yield* _vendorProfileController.stream;
  }

  @override
  Future<Vendor> updateStoreStatus(String vendorId, {required bool isOpen}) async {
    final existing = _vendors[vendorId] ?? _vendors['store-1']!;
    final updated = Vendor(
      id: existing.id,
      storeName: existing.storeName,
      slug: existing.slug,
      description: existing.description,
      logoUrl: existing.logoUrl,
      bannerUrl: existing.bannerUrl,
      address: existing.address,
      latitude: existing.latitude,
      longitude: existing.longitude,
      phone: existing.phone,
      commissionRate: existing.commissionRate,
      isOpen: isOpen,
      isVerified: existing.isVerified,
      createdAt: existing.createdAt,
    );
    _vendors[existing.id] = updated;
    _vendorProfileController.add(updated);
    return updated;
  }

  @override
  Future<List<MarketplaceOrder>> getVendorOrders(String vendorId, {OrderStatus? status}) async {
    if (status != null) {
      return _orders.where((o) => o.status == status).toList();
    }
    return List.unmodifiable(_orders);
  }

  @override
  Stream<List<MarketplaceOrder>> streamVendorOrders(String vendorId, {OrderStatus? status}) async* {
    yield await getVendorOrders(vendorId, status: status);
    yield* _vendorOrdersController.stream;
  }

  @override
  Future<MarketplaceOrder> updateOrderStatus(String orderId, OrderStatus newStatus, {String? notes}) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final existing = _orders[index];
      final updated = MarketplaceOrder(
        id: existing.id,
        orderNumber: existing.orderNumber,
        customerId: existing.customerId,
        vendorId: existing.vendorId,
        subtotal: existing.subtotal,
        deliveryFee: existing.deliveryFee,
        platformFee: existing.platformFee,
        totalAmount: existing.totalAmount,
        status: newStatus,
        paymentMethod: existing.paymentMethod,
        paymentStatus: newStatus == OrderStatus.delivered ? 'paid' : existing.paymentStatus,
        deliveryAddress: existing.deliveryAddress,
        deliveryLat: existing.deliveryLat,
        deliveryLng: existing.deliveryLng,
        customerNotes: existing.customerNotes,
        items: existing.items,
        createdAt: existing.createdAt,
      );
      _orders[index] = updated;
      _vendorOrdersController.add(List.unmodifiable(_orders));
      return updated;
    }
    throw Exception('Order not found');
  }
}
