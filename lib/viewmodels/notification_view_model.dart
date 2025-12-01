import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/notification_service.dart';
import '../models/notification_models.dart';
import '../models/api_error.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  UnreadCountResponse? _unreadCount;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  ApiError? _error;
  String? _currentCategory;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<AppNotification> get notifications => _notifications;
  UnreadCountResponse? get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  ApiError? get error => _error;
  String? get currentCategory => _currentCategory;
  int get totalUnread => _unreadCount?.total ?? 0;

  // Initialize notification service
  Future<void> initialize({Function(RemoteMessage)? onMessageTapped}) async {
    developer.log('🔵 Initializing NotificationViewModel...');
    await _notificationService.initialize(onMessageTapped: onMessageTapped);
    await Future.wait([loadNotifications(), loadUnreadCount()]);
  }

  // Load notifications
  Future<void> loadNotifications({String? category}) async {
    if (category != null && category != _currentCategory) {
      _currentCategory = category;
      _currentPage = 1;
      _notifications.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log('🔵 Loading notifications for category: $_currentCategory');

      final response = await _notificationService.getNotifications(
        category: _currentCategory,
        page: _currentPage,
        limit: 20,
      );

      if (response != null) {
        _notifications = response.notifications;
        _hasMore = response.hasMore;
        developer.log('✅ Loaded ${_notifications.length} notifications');
      }
    } catch (e) {
      developer.log('🔴 Error loading notifications: $e');
      _error = e is ApiError
          ? e
          : ApiError(errorCode: 'UNKNOWN_ERROR', message: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more notifications
  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await _notificationService.getNotifications(
        category: _currentCategory,
        page: _currentPage,
        limit: 20,
      );

      if (response != null) {
        _notifications.addAll(response.notifications);
        _hasMore = response.hasMore;
      }
    } catch (e) {
      developer.log('🔴 Error loading more notifications: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load unread count
  Future<void> loadUnreadCount({String? category}) async {
    try {
      final response = await _notificationService.getUnreadCount(
        category: category ?? _currentCategory,
      );
      if (response != null) {
        _unreadCount = response;
        notifyListeners();
      }
    } catch (e) {
      developer.log('🔴 Error loading unread count: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Reload to get updated state
          await loadUnreadCount();
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log('🔴 Error marking as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      developer.log('🔵 Marking all as read for category: $_currentCategory');
      final success = await _notificationService.markAllAsRead(
        category: _currentCategory,
      );
      if (success) {
        await Future.wait([loadNotifications(), loadUnreadCount()]);
      }
    } catch (e) {
      developer.log('🔴 Error marking all as read: $e');
    }
  }

  // Dismiss notification
  Future<void> dismissNotification(String notificationId) async {
    try {
      final success = await _notificationService.dismissNotification(
        notificationId,
      );
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        await loadUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      developer.log('🔴 Error dismissing notification: $e');
    }
  }

  // Handle notification action
  Future<bool> handleAction(String notificationId, String action) async {
    try {
      developer.log('🔵 Handling action: $action');
      final success = await _notificationService.handleAction(
        notificationId,
        action,
      );
      if (success) {
        await Future.wait([loadNotifications(), loadUnreadCount()]);
      }
      return success;
    } catch (e) {
      developer.log('🔴 Error handling action: $e');
      return false;
    }
  }

  // Refresh notifications
  Future<void> refresh() async {
    _currentPage = 1;
    _notifications.clear();
    _hasMore = true;
    await Future.wait([loadNotifications(), loadUnreadCount()]);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if should navigate to login
  bool shouldNavigateToLogin() {
    return _error?.statusCode == 401;
  }
}
