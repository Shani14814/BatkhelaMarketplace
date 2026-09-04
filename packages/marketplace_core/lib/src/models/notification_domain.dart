enum NotificationType {
  orderPlaced,
  orderAccepted,
  orderPreparing,
  orderReadyForPickup,
  orderOutForDelivery,
  orderDelivered,
  orderCancelled,
  newIncomingOrder,
  riderArrived,
  deliveryOffer,
  deliveryAssigned,
  newVendorKyc,
  newRiderKyc,
  systemAlert;

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'order_placed':
        return NotificationType.orderPlaced;
      case 'order_accepted':
        return NotificationType.orderAccepted;
      case 'order_preparing':
        return NotificationType.orderPreparing;
      case 'order_ready_for_pickup':
        return NotificationType.orderReadyForPickup;
      case 'order_out_for_delivery':
        return NotificationType.orderOutForDelivery;
      case 'order_delivered':
        return NotificationType.orderDelivered;
      case 'order_cancelled':
        return NotificationType.orderCancelled;
      case 'new_incoming_order':
        return NotificationType.newIncomingOrder;
      case 'rider_arrived':
        return NotificationType.riderArrived;
      case 'delivery_offer':
        return NotificationType.deliveryOffer;
      case 'delivery_assigned':
        return NotificationType.deliveryAssigned;
      case 'new_vendor_kyc':
        return NotificationType.newVendorKyc;
      case 'new_rider_kyc':
        return NotificationType.newRiderKyc;
      case 'system_alert':
      default:
        return NotificationType.systemAlert;
    }
  }

  String toDbString() {
    switch (this) {
      case NotificationType.orderPlaced:
        return 'order_placed';
      case NotificationType.orderAccepted:
        return 'order_accepted';
      case NotificationType.orderPreparing:
        return 'order_preparing';
      case NotificationType.orderReadyForPickup:
        return 'order_ready_for_pickup';
      case NotificationType.orderOutForDelivery:
        return 'order_out_for_delivery';
      case NotificationType.orderDelivered:
        return 'order_delivered';
      case NotificationType.orderCancelled:
        return 'order_cancelled';
      case NotificationType.newIncomingOrder:
        return 'new_incoming_order';
      case NotificationType.riderArrived:
        return 'rider_arrived';
      case NotificationType.deliveryOffer:
        return 'delivery_offer';
      case NotificationType.deliveryAssigned:
        return 'delivery_assigned';
      case NotificationType.newVendorKyc:
        return 'new_vendor_kyc';
      case NotificationType.newRiderKyc:
        return 'new_rider_kyc';
      case NotificationType.systemAlert:
        return 'system_alert';
    }
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  static NotificationPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      case 'normal':
      default:
        return NotificationPriority.normal;
    }
  }

  String toDbString() {
    switch (this) {
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.normal:
        return 'normal';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.urgent:
        return 'urgent';
    }
  }
}

class MarketplaceNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final String? targetRole;
  final String? orderId;
  final String? deliveryId;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const MarketplaceNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.targetRole,
    this.orderId,
    this.deliveryId,
    this.payload = const {},
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  MarketplaceNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    String? targetRole,
    String? orderId,
    String? deliveryId,
    Map<String, dynamic>? payload,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return MarketplaceNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      targetRole: targetRole ?? this.targetRole,
      orderId: orderId ?? this.orderId,
      deliveryId: deliveryId ?? this.deliveryId,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory MarketplaceNotification.fromJson(Map<String, dynamic> json) {
    return MarketplaceNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? 'system_alert'),
      priority: NotificationPriority.fromString(json['priority'] as String? ?? 'normal'),
      targetRole: json['target_role'] as String?,
      orderId: json['order_id'] as String?,
      deliveryId: json['delivery_id'] as String?,
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.toDbString(),
      'priority': priority.toDbString(),
      'target_role': targetRole,
      'order_id': orderId,
      'delivery_id': deliveryId,
      'payload': payload,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}
