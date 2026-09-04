import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

class NotificationInboxSheet extends StatefulWidget {
  final String userId;
  final String role;
  final void Function(MarketplaceNotification)? onNotificationTap;

  const NotificationInboxSheet({
    super.key,
    required this.userId,
    required this.role,
    this.onNotificationTap,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required String role,
    void Function(MarketplaceNotification)? onNotificationTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationInboxSheet(
        userId: userId,
        role: role,
        onNotificationTap: onNotificationTap,
      ),
    );
  }

  @override
  State<NotificationInboxSheet> createState() => _NotificationInboxSheetState();
}

class _NotificationInboxSheetState extends State<NotificationInboxSheet> {
  final _dataService = MarketplaceDataService.instance;
  List<MarketplaceNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifs = await _dataService.notificationRepo.getNotifications(
      userId: widget.userId,
      role: widget.role,
    );
    if (mounted) {
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await _dataService.notificationController.markAllAsRead();
    await _loadNotifications();
  }

  Future<void> _handleTap(MarketplaceNotification item) async {
    if (!item.isRead) {
      await _dataService.notificationController.markAsRead(item.id);
      await _loadNotifications();
    }
    if (mounted) {
      Navigator.pop(context);
    }
    widget.onNotificationTap?.call(item);
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
      case NotificationType.orderAccepted:
        return Icons.check_circle_outline;
      case NotificationType.orderPreparing:
        return Icons.restaurant;
      case NotificationType.orderReadyForPickup:
        return Icons.inventory_2_outlined;
      case NotificationType.orderOutForDelivery:
      case NotificationType.deliveryOffer:
      case NotificationType.deliveryAssigned:
      case NotificationType.riderArrived:
        return Icons.two_wheeler;
      case NotificationType.orderDelivered:
        return Icons.celebration_outlined;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.newIncomingOrder:
        return Icons.notifications_active;
      case NotificationType.newVendorKyc:
      case NotificationType.newRiderKyc:
        return Icons.assignment_ind_outlined;
      case NotificationType.systemAlert:
        return Icons.info_outline;
    }
  }

  Color _getColorForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return AppColors.error;
      case NotificationPriority.high:
        return AppColors.coral;
      case NotificationPriority.normal:
      case NotificationPriority.low:
        return AppColors.primary;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_notifications.any((n) => !n.isRead)) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_notifications.where((n) => !n.isRead).length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_notifications.any((n) => !n.isRead))
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 56, color: AppColors.textTertiary),
                            SizedBox(height: 12),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You will receive updates on your orders and tasks here.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final iconColor = _getColorForPriority(item.priority);

                          return InkWell(
                            onTap: () => _handleTap(item),
                            child: Container(
                              color: item.isRead ? Colors.transparent : AppColors.primary.withAlpha(12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: iconColor.withAlpha(30),
                                    child: Icon(_getIconForType(item.type), color: iconColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatTimeAgo(item.createdAt),
                                              style: const TextStyle(
                                                color: AppColors.textTertiary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.body,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!item.isRead) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.coral,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
