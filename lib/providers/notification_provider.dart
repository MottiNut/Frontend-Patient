import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/service/firebase_service.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<NotificationModel>? _notificationSubscription;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnreadNotifications => unreadCount > 0;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _firebaseService.initialize();
      _loadNotifications();
      _setupNotificationListener();
      _clearError();
    } catch (e) {
      _setError('Error inicializando notificaciones: $e');
      debugPrint('Error in NotificationProvider.initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setupNotificationListener() {
    _notificationSubscription?.cancel();
    _notificationSubscription = _firebaseService.onNotificationReceived.listen(
          (notification) {
        _notifications.insert(0, notification);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error recibiendo notificación: $error');
      },
    );
  }

  void _loadNotifications() {
    _notifications = List.from(_firebaseService.notifications);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _firebaseService.markAsRead(notificationId);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      _firebaseService.markAllAsRead();
      notifyListeners();
    }
  }

  void clearAll() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      _firebaseService.clearAll();
      notifyListeners();
    }
  }

  // Método que faltaba en tu código original
  void deleteNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<NotificationModel> getTodaysNotifications() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _notifications.where((n) =>
    n.timestamp.isAfter(startOfDay) &&
        n.timestamp.isBefore(endOfDay)
    ).toList();
  }

  List<NotificationModel> getWeekNotifications() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _notifications.where((n) => n.timestamp.isAfter(weekAgo)).toList();
  }

  Future<void> refresh() async {
    _setLoading(true);
    try {
      _loadNotifications();
      _clearError();
    } catch (e) {
      _setError('Error actualizando notificaciones: $e');
    } finally {
      _setLoading(false);
    }
  }

  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}