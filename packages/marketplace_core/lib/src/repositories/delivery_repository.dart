import 'dart:async';
import '../models/delivery.dart';

abstract class DeliveryRepository {
  Future<List<DeliveryTask>> getAssignedDeliveries(String riderId);
  Future<List<DeliveryTask>> getAvailableDeliveries();
  Future<DeliveryTask> acceptDelivery(String taskId, String riderId);
  Future<DeliveryTask> updateDeliveryStatus(
    String taskId,
    DeliveryStatus status, {
    String? proofImageUrl,
  });
  Future<DeliveryTask?> getDeliveryByOrderId(String orderId);

  // Realtime Streams (Phase 7E)
  Stream<List<DeliveryTask>> streamRiderDeliveries(String riderId);
  Stream<List<DeliveryTask>> streamAvailableDeliveries();
  Stream<DeliveryTask?> streamDeliveryForOrder(String orderId);
}
