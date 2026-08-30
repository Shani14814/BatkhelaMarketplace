enum OrderStatus {
  placed,
  accepted,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'placed':
      default:
        return OrderStatus.placed;
    }
  }

  String toDbString() {
    switch (this) {
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.readyForPickup:
        return 'ready_for_pickup';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.placed:
        return 'placed';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Accepted by Store';
      case OrderStatus.preparing:
        return 'Preparing Food/Items';
      case OrderStatus.readyForPickup:
        return 'Ready for Rider';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}

class MarketplaceOrder {
  final String id;
  final int? orderNumber;
  final String customerId;
  final String vendorId;
  final double subtotal;
  final double deliveryFee;
  final double platformFee;
  final double totalAmount;
  final OrderStatus status;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? customerNotes;
  final List<OrderItem> items;
  final DateTime createdAt;

  const MarketplaceOrder({
    required this.id,
    this.orderNumber,
    required this.customerId,
    required this.vendorId,
    required this.subtotal,
    this.deliveryFee = 0.0,
    this.platformFee = 0.0,
    required this.totalAmount,
    required this.status,
    this.paymentMethod = 'cash_on_delivery',
    this.paymentStatus = 'pending',
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.customerNotes,
    this.items = const [],
    required this.createdAt,
  });

  factory MarketplaceOrder.fromJson(Map<String, dynamic> json, {List<OrderItem> items = const []}) {
    return MarketplaceOrder(
      id: json['id'] as String,
      orderNumber: (json['order_number'] as num?)?.toInt(),
      customerId: json['customer_id'] as String,
      vendorId: json['vendor_id'] as String,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(json['status'] as String? ?? 'placed'),
      paymentMethod: json['payment_method'] as String? ?? 'cash_on_delivery',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      customerNotes: json['customer_notes'] as String?,
      items: items,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'vendor_id': vendorId,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'platform_fee': platformFee,
      'total_amount': totalAmount,
      'status': status.toDbString(),
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'customer_notes': customerNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
