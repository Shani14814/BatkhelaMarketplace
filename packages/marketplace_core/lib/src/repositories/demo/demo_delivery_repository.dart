import '../../models/delivery.dart';
import '../delivery_repository.dart';

class DemoDeliveryRepository implements DeliveryRepository {
  final List<DeliveryTask> _tasks = [
    DeliveryTask(
      id: 'del-101',
      orderId: 'ord-1002',
      riderId: 'demo-role-rider',
      status: DeliveryStatus.pickedUp,
      pickupTime: DateTime.now().subtract(const Duration(minutes: 15)),
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    DeliveryTask(
      id: 'del-102',
      orderId: 'ord-1001',
      riderId: null,
      status: DeliveryStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  @override
  Future<List<DeliveryTask>> getAssignedDeliveries(String riderId) async {
    return _tasks.where((t) => t.riderId == riderId || t.riderId == 'demo-role-rider').toList();
  }

  @override
  Future<List<DeliveryTask>> getAvailableDeliveries() async {
    return _tasks.where((t) => t.status == DeliveryStatus.pending && t.riderId == null).toList();
  }

  @override
  Future<DeliveryTask> acceptDelivery(String taskId, String riderId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updated = DeliveryTask(
        id: _tasks[index].id,
        orderId: _tasks[index].orderId,
        riderId: riderId,
        status: DeliveryStatus.assigned,
        createdAt: _tasks[index].createdAt,
      );
      _tasks[index] = updated;
      return updated;
    }
    throw Exception('Delivery task not found');
  }

  @override
  Future<DeliveryTask> updateDeliveryStatus(
    String taskId,
    DeliveryStatus status, {
    String? proofImageUrl,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final existing = _tasks[index];
      final updated = DeliveryTask(
        id: existing.id,
        orderId: existing.orderId,
        riderId: existing.riderId,
        status: status,
        pickupTime: status == DeliveryStatus.pickedUp ? DateTime.now() : existing.pickupTime,
        deliveredTime: status == DeliveryStatus.delivered ? DateTime.now() : existing.deliveredTime,
        proofImageUrl: proofImageUrl ?? existing.proofImageUrl,
        createdAt: existing.createdAt,
      );
      _tasks[index] = updated;
      return updated;
    }
    throw Exception('Delivery task not found');
  }

  @override
  Future<DeliveryTask?> getDeliveryByOrderId(String orderId) async {
    final match = _tasks.where((t) => t.orderId == orderId);
    return match.isNotEmpty ? match.first : null;
  }
}
