import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/delivery.dart';
import '../delivery_repository.dart';

class SupabaseDeliveryRepository implements DeliveryRepository {
  final SupabaseClient _client;

  SupabaseDeliveryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<DeliveryTask>> getAssignedDeliveries(String riderId) async {
    final response = await _client
        .from('deliveries')
        .select()
        .eq('rider_id', riderId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DeliveryTask.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DeliveryTask>> getAvailableDeliveries() async {
    final response = await _client
        .from('deliveries')
        .select()
        .eq('status', DeliveryStatus.pending.toDbString())
        .isFilter('rider_id', null)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => DeliveryTask.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DeliveryTask> acceptDelivery(String taskId, String riderId) async {
    final response = await _client
        .from('deliveries')
        .update({
          'rider_id': riderId,
          'status': DeliveryStatus.assigned.toDbString(),
        })
        .eq('id', taskId)
        .select()
        .single();

    return DeliveryTask.fromJson(response);
  }

  @override
  Future<DeliveryTask> updateDeliveryStatus(
    String taskId,
    DeliveryStatus status, {
    String? proofImageUrl,
  }) async {
    final response = await _client
        .from('deliveries')
        .update({
          'status': status.toDbString(),
          if (status == DeliveryStatus.pickedUp) 'pickup_time': DateTime.now().toIso8601String(),
          if (status == DeliveryStatus.delivered) 'delivered_time': DateTime.now().toIso8601String(),
          'proof_image_url': ?proofImageUrl,
        })
        .eq('id', taskId)
        .select()
        .single();

    return DeliveryTask.fromJson(response);
  }

  @override
  Future<DeliveryTask?> getDeliveryByOrderId(String orderId) async {
    final response = await _client
        .from('deliveries')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();

    if (response == null) return null;
    return DeliveryTask.fromJson(response);
  }
}
