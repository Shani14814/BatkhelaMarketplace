import 'dart:async';
import '../../models/order.dart';
import '../order_repository.dart';

class DemoOrderRepository implements OrderRepository {
  final _ordersController = StreamController<List<MarketplaceOrder>>.broadcast();

  final List<MarketplaceOrder> _orders = [
    MarketplaceOrder(
      id: 'ord-1001',
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
          orderId: 'ord-1001',
          productName: 'Special Shinwari Mutton Karahi (1 KG)',
          unitPrice: 2250.0,
          quantity: 1,
          totalPrice: 2250.0,
        ),
        OrderItem(
          id: 'item-2',
          orderId: 'ord-1001',
          productName: 'Peshawari Chapli Kabab (Plate)',
          unitPrice: 400.0,
          quantity: 1,
          totalPrice: 400.0,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    MarketplaceOrder(
      id: 'ord-1002',
      orderNumber: 1041,
      customerId: 'demo-cust-2',
      vendorId: 'store-1',
      subtotal: 1800.0,
      deliveryFee: 100.0,
      platformFee: 25.0,
      totalAmount: 1925.0,
      status: OrderStatus.outForDelivery,
      paymentMethod: 'cash_on_delivery',
      paymentStatus: 'pending',
      deliveryAddress: 'Near Degree College, Batkhela',
      items: const [
        OrderItem(
          id: 'item-3',
          orderId: 'ord-1002',
          productName: 'Chicken Karahi Special (Full)',
          unitPrice: 1400.0,
          quantity: 1,
          totalPrice: 1400.0,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
  ];

  @override
  Future<MarketplaceOrder?> getOrderById(String orderId) async {
    final match = _orders.where((o) => o.id == orderId);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Stream<MarketplaceOrder?> streamOrder(String orderId) async* {
    yield await getOrderById(orderId);
    yield* _ordersController.stream.map((list) {
      final match = list.where((o) => o.id == orderId);
      return match.isNotEmpty ? match.first : null;
    });
  }

  @override
  Future<MarketplaceOrder> placeOrder(MarketplaceOrder order) async {
    // Trusted calculation on server
    double subtotal = 0.0;
    for (final item in order.items) {
      subtotal += item.totalPrice;
    }
    final trustedTotal = subtotal + order.deliveryFee + order.platformFee;

    final placedOrder = MarketplaceOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 1000 + _orders.length + 1,
      customerId: order.customerId,
      vendorId: order.vendorId,
      subtotal: subtotal > 0 ? subtotal : order.subtotal,
      deliveryFee: order.deliveryFee,
      platformFee: order.platformFee,
      totalAmount: trustedTotal > 0 ? trustedTotal : order.totalAmount,
      status: OrderStatus.placed,
      paymentMethod: order.paymentMethod,
      paymentStatus: 'pending',
      deliveryAddress: order.deliveryAddress,
      deliveryLat: order.deliveryLat,
      deliveryLng: order.deliveryLng,
      customerNotes: order.customerNotes,
      items: order.items,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, placedOrder);
    _ordersController.add(List.unmodifiable(_orders));
    return placedOrder;
  }

  @override
  Future<MarketplaceOrder> updateStatus(String orderId, OrderStatus status, {String? notes}) async {
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
        status: status,
        paymentMethod: existing.paymentMethod,
        paymentStatus: status == OrderStatus.delivered ? 'paid' : existing.paymentStatus,
        deliveryAddress: existing.deliveryAddress,
        deliveryLat: existing.deliveryLat,
        deliveryLng: existing.deliveryLng,
        customerNotes: notes ?? existing.customerNotes,
        items: existing.items,
        createdAt: existing.createdAt,
      );
      _orders[index] = updated;
      _ordersController.add(List.unmodifiable(_orders));
      return updated;
    }
    throw Exception('Order not found');
  }

  @override
  Future<List<MarketplaceOrder>> getOrdersForCustomer(String customerId) async {
    return _orders.where((o) => o.customerId == customerId || customerId.startsWith('demo-user')).toList();
  }

  @override
  Stream<List<MarketplaceOrder>> streamOrdersForCustomer(String customerId) async* {
    yield await getOrdersForCustomer(customerId);
    yield* _ordersController.stream.map((list) =>
        list.where((o) => o.customerId == customerId || customerId.startsWith('demo-user')).toList());
  }

  @override
  Future<List<MarketplaceOrder>> getOrdersForVendor(String vendorId, {OrderStatus? status}) async {
    var result = _orders.where((o) => o.vendorId == vendorId).toList();
    if (status != null) {
      result = result.where((o) => o.status == status).toList();
    }
    return result;
  }

  @override
  Stream<List<MarketplaceOrder>> streamOrdersForVendor(String vendorId, {OrderStatus? status}) async* {
    yield await getOrdersForVendor(vendorId, status: status);
    yield* _ordersController.stream.map((list) {
      var filtered = list.where((o) => o.vendorId == vendorId).toList();
      if (status != null) {
        filtered = filtered.where((o) => o.status == status).toList();
      }
      return filtered;
    });
  }

  @override
  Future<List<MarketplaceOrder>> getAllOrders({OrderStatus? status}) async {
    if (status != null) {
      return _orders.where((o) => o.status == status).toList();
    }
    return List.unmodifiable(_orders);
  }
}
