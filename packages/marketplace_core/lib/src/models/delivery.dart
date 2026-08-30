enum DeliveryStatus {
  pending,
  assigned,
  pickedUp,
  delivered,
  failed;

  static DeliveryStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return DeliveryStatus.assigned;
      case 'picked_up':
        return DeliveryStatus.pickedUp;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'failed':
        return DeliveryStatus.failed;
      case 'pending':
      default:
        return DeliveryStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'assigned';
      case DeliveryStatus.pickedUp:
        return 'picked_up';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.failed:
        return 'failed';
      case DeliveryStatus.pending:
        return 'pending';
    }
  }
}

class DeliveryTask {
  final String id;
  final String orderId;
  final String? riderId;
  final DeliveryStatus status;
  final DateTime? pickupTime;
  final DateTime? deliveredTime;
  final String? proofImageUrl;
  final DateTime createdAt;

  const DeliveryTask({
    required this.id,
    required this.orderId,
    this.riderId,
    required this.status,
    this.pickupTime,
    this.deliveredTime,
    this.proofImageUrl,
    required this.createdAt,
  });

  factory DeliveryTask.fromJson(Map<String, dynamic> json) {
    return DeliveryTask(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      riderId: json['rider_id'] as String?,
      status: DeliveryStatus.fromString(json['status'] as String? ?? 'pending'),
      pickupTime: json['pickup_time'] != null ? DateTime.tryParse(json['pickup_time'] as String) : null,
      deliveredTime: json['delivered_time'] != null ? DateTime.tryParse(json['delivered_time'] as String) : null,
      proofImageUrl: json['proof_image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'rider_id': riderId,
      'status': status.toDbString(),
      'pickup_time': pickupTime?.toIso8601String(),
      'delivered_time': deliveredTime?.toIso8601String(),
      'proof_image_url': proofImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class RiderLocation {
  final String riderId;
  final double latitude;
  final double longitude;
  final double heading;
  final bool isOnline;
  final DateTime updatedAt;

  const RiderLocation({
    required this.riderId,
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.isOnline = false,
    required this.updatedAt,
  });

  factory RiderLocation.fromJson(Map<String, dynamic> json) {
    return RiderLocation(
      riderId: json['rider_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['is_online'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rider_id': riderId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'is_online': isOnline,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
