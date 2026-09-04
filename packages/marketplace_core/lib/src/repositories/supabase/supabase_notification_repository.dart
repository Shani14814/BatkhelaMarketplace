import '../../models/notification_domain.dart';
import '../../services/supabase_service.dart';
import '../notification_repository.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseService _supabaseService;

  SupabaseNotificationRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  @override
  Future<List<MarketplaceNotification>> getNotifications({
    required String userId,
    String? role,
  }) async {
    try {
      var query = _supabaseService.client
          .from('notifications')
          .select('*')
          .eq('user_id', userId);

      if (role != null) {
        query = query.eq('target_role', role);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => MarketplaceNotification.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> getUnreadCount({
    required String userId,
    String? role,
  }) async {
    try {
      var query = _supabaseService.client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      if (role != null) {
        query = query.eq('target_role', role);
      }

      final response = await query;
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabaseService.client.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (_) {}
  }

  @override
  Future<void> markAllAsRead({
    required String userId,
    String? role,
  }) async {
    try {
      var query = _supabaseService.client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);

      if (role != null) {
        query = query.eq('target_role', role);
      }

      await query;
    } catch (_) {}
  }

  @override
  Future<MarketplaceNotification> sendNotification(MarketplaceNotification notification) async {
    try {
      final response = await _supabaseService.client
          .from('notifications')
          .insert(notification.toJson())
          .select()
          .single();
      return MarketplaceNotification.fromJson(response);
    } catch (_) {
      return notification;
    }
  }

  @override
  Stream<List<MarketplaceNotification>> streamNotifications({
    required String userId,
    String? role,
  }) {
    try {
      return _supabaseService.client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map((data) => data.map((json) => MarketplaceNotification.fromJson(json)).toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabaseService.client.from('notifications').delete().eq('id', notificationId);
    } catch (_) {}
  }
}
