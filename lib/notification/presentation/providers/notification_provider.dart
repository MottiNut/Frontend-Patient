import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/notification/application/services/firebase_service.dart';
import '../../domain/models/notification.dart';
import '../../domain/models/notification_type.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<NotificationModel>? _notificationSubscription;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  bool _isInitialized = false; // ✅ NUEVO: Control de inicialización

  // Getters
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnreadNotifications => unreadCount > 0;

  // ✅ SIMPLIFICADO: Inicialización una sola vez
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationProvider already initialized');
      return;
    }

    debugPrint('🔄 NotificationProvider.initialize()');
    _setLoading(true);

    try {
      await _firebaseService.initialize();
      _clearError();
      _isInitialized = true;
      debugPrint('✅ NotificationProvider initialized successfully');
    } catch (e) {
      _setError('Error inicializando notificaciones: $e');
      debugPrint('❌ Error in NotificationProvider.initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> onUserLoggedIn(String userId) async {
    if (_currentUserId == userId) {
      debugPrint('⚠️ Same user already logged in: $userId');
      return;
    }

    debugPrint('👤 NotificationProvider: User logged in: $userId');
    _currentUserId = userId;
    _setLoading(true);

    try {
      // ✅ PASO 1: Configurar Firebase Service
      await _firebaseService.onUserLoggedIn(userId);

      // ✅ PASO 2: Cargar notificaciones
      _loadNotifications();

      // ✅ PASO 3: Configurar listener
      _setupNotificationListener();

      _clearError();
      debugPrint('✅ User configured with ${_notifications.length} notifications');
    } catch (e) {
      _setError('Error al configurar notificaciones para el usuario: $e');
      debugPrint('❌ Error in onUserLoggedIn: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> onUserLoggedOut() async {
    if (_currentUserId == null) {
      debugPrint('⚠️ No user currently logged in');
      return;
    }

    debugPrint('👋 NotificationProvider: User logged out: $_currentUserId');

    try {
      // ✅ CANCELAR: Listener primero
      _notificationSubscription?.cancel();
      _notificationSubscription = null;

      // ✅ NOTIFICAR: Firebase Service
      await _firebaseService.onUserLoggedOut();

      // ✅ LIMPIAR: Datos locales
      _currentUserId = null;
      _notifications.clear();
      _clearError();

      notifyListeners();
      debugPrint('✅ User logged out successfully');
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
      debugPrint('❌ Error in onUserLoggedOut: $e');
    }
  }

  void _setupNotificationListener() {
    // ✅ CANCELAR: Listener anterior
    _notificationSubscription?.cancel();

    _notificationSubscription = _firebaseService.onNotificationReceived.listen(
          (notification) {
        debugPrint('📨 New notification received: ${notification.title}');

        if (_currentUserId != null) {
          // ✅ VERIFICAR: Duplicados
          final exists = _notifications.any((n) => n.id == notification.id);
          if (!exists) {
            _notifications.insert(0, notification);
            notifyListeners();
            debugPrint('✅ Notification added. Total: ${_notifications.length}');
          }
        }
      },
      onError: (error) {
        _setError('Error recibiendo notificación: $error');
        debugPrint('❌ Error in notification listener: $error');
      },
    );

    debugPrint('👂 Notification listener configured');
  }

  void _loadNotifications() {
    debugPrint('📋 Loading notifications from FirebaseService...');
    final firebaseNotifications = _firebaseService.notifications;
    _notifications = List.from(firebaseNotifications);
    debugPrint('✅ Loaded ${_notifications.length} notifications');
    notifyListeners();
  }

  // ✅ SIMPLIFICADO: Métodos de manipulación
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

  void deleteNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      _firebaseService.removeNotification(notificationId);
      notifyListeners();
    }
  }

  // ✅ MÉTODOS DE FILTRADO
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

  Future<void> refresh() async {
    debugPrint('🔄 Refreshing notifications...');
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

  // ✅ MÉTODOS PRIVADOS
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
    debugPrint('🧹 Disposing NotificationProvider');
    _notificationSubscription?.cancel();
    super.dispose();
  }
}