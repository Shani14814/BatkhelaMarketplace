import 'dart:async';

/// Centralized Realtime Subscription Lifecycle Manager
/// Ensures no subscription memory leaks, duplicate channels, or stale streams
/// on screen dispose, logout, role switch, or environment change.
class RealtimeSubscriptionManager {
  static final RealtimeSubscriptionManager instance = RealtimeSubscriptionManager._internal();
  RealtimeSubscriptionManager._internal();

  final Map<String, StreamSubscription<dynamic>> _activeSubscriptions = {};

  /// Register a managed subscription with a unique key
  void register(String key, StreamSubscription<dynamic> subscription) {
    cancel(key); // Cancel any previous instance on the same key
    _activeSubscriptions[key] = subscription;
  }

  /// Cancel a specific subscription by key
  Future<void> cancel(String key) async {
    final sub = _activeSubscriptions.remove(key);
    if (sub != null) {
      await sub.cancel();
    }
  }

  /// Cancel all subscriptions matching a key prefix (e.g., 'customer_', 'vendor_', 'rider_')
  Future<void> cancelByPrefix(String prefix) async {
    final keysToCancel = _activeSubscriptions.keys.where((k) => k.startsWith(prefix)).toList();
    for (final key in keysToCancel) {
      await cancel(key);
    }
  }

  /// Cancel and dispose all active subscriptions (used on logout and mode change)
  Future<void> cancelAll() async {
    final current = List<StreamSubscription<dynamic>>.from(_activeSubscriptions.values);
    _activeSubscriptions.clear();
    for (final sub in current) {
      await sub.cancel();
    }
  }

  /// Current active subscriptions count (useful for diagnostics and unit tests)
  int get activeCount => _activeSubscriptions.length;

  /// Check if a subscription key is currently active
  bool isActive(String key) => _activeSubscriptions.containsKey(key);
}
