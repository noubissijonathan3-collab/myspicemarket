import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  bool _hasMore = true;
  int _currentPage = 1;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;

  StreamSubscription? _notificationSubscription;
  StreamSubscription? _countSubscription;

  void _onNewNotification(NotificationModel notif) {
    _notifications.insert(0, notif);
    if (!notif.isRead) _unreadCount++;
    notifyListeners();
  }

  void _onUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  void attachRealtimeListeners(Stream<NotificationModel> notificationStream, Stream<int> countStream) {
    _notificationSubscription?.cancel();
    _countSubscription?.cancel();
    _notificationSubscription = notificationStream.listen(_onNewNotification);
    _countSubscription = countStream.listen(_onUnreadCount);
  }

  Future<void> loadNotifications({String? category, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications = [];
    }

    _selectedCategory = category;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await NotificationService.fetchNotifications(
        category: category,
        page: _currentPage,
        limit: 30,
      );
      final newNotifs = data['notifications'] as List<NotificationModel>;
      if (refresh || _currentPage == 1) {
        _notifications = newNotifs;
      } else {
        _notifications = [..._notifications, ...newNotifs];
      }
      _unreadCount = data['unreadCount'] as int;
      _hasMore = _currentPage < (data['totalPages'] as int);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await loadNotifications(category: _selectedCategory);
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await NotificationService.fetchUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      await NotificationService.markAsRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx] = NotificationModel(
          id: _notifications[idx].id,
          title: _notifications[idx].title,
          message: _notifications[idx].message,
          type: _notifications[idx].type,
          category: _notifications[idx].category,
          priority: _notifications[idx].priority,
          orderId: _notifications[idx].orderId,
          isRead: true,
          readAt: DateTime.now(),
          actionLink: _notifications[idx].actionLink,
          actionType: _notifications[idx].actionType,
          metadata: _notifications[idx].metadata,
          createdAt: _notifications[idx].createdAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead(category: _selectedCategory);
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        category: n.category,
        priority: n.priority,
        orderId: n.orderId,
        isRead: true,
        readAt: DateTime.now(),
        actionLink: n.actionLink,
        actionType: n.actionType,
        metadata: n.metadata,
        createdAt: n.createdAt,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await NotificationService.deleteNotification(id);
      final wasUnread = _notifications.any((n) => n.id == id && !n.isRead);
      _notifications.removeWhere((n) => n.id == id);
      if (wasUnread) _unreadCount = (_unreadCount - 1).clamp(0, 999);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await NotificationService.clearAll(category: _selectedCategory);
      if (_selectedCategory != null) {
        _notifications.removeWhere((n) => n.category == _selectedCategory);
      } else {
        _notifications = [];
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _selectedCategory = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _countSubscription?.cancel();
    super.dispose();
  }
}
