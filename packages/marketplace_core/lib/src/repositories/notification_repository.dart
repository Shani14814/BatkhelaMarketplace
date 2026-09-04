import '../models/notification_domain.dart';

abstract class NotificationRepository {
  /// Fetch all notifications for a specific user, optionally filtered by role
  Future<List<MarketplaceNotification>> getNotifications({
    required String userId,
    String? role,
  });

  /// Get current unread notifications count
  Future<int> getUnreadCount({
    required String userId,
    String? role,
  });

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead({
    required String userId,
    String? role,
  });

  /// Dispatch or create a new notification
  Future<MarketplaceNotification> sendNotification(MarketplaceNotification notification);

  /// Stream notifications reactively
  Stream<List<MarketplaceNotification>> streamNotifications({
    required String userId,
    String? role,
  });

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);
}
