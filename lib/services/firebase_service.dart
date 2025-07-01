import 'dart:convert';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification/notification_model.dart';
import '../models/notification/notification_type.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _deviceToken;
  String? _currentUserId;
  final List<NotificationModel> _notifications = [];
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String notificationsKey = 'stored_notifications'; // ✅ NUEVO: Clave para persistir notificaciones

  final Set<String> _processedMessages = <String>{};
  bool _isInitialized = false;

  static const String _baseUrl = 'https://mottinut-backend-2025-djf0f5c0hjckhpgp.centralus-01.azurewebsites.net';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  Stream<NotificationModel> get onNotificationReceived => _notificationController.stream;
  final _notificationController = StreamController<NotificationModel>.broadcast();

  // ✅ NUEVO: Método para persistir notificaciones
  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString('${notificationsKey}_$_currentUserId', jsonEncode(notificationsJson));
      debugPrint('✅ Notificaciones guardadas: ${_notifications.length}');
    } catch (e) {
      debugPrint('❌ Error guardando notificaciones: $e');
    }
  }

  // ✅ NUEVO: Método para cargar notificaciones persistidas
  Future<void> _loadNotificationsFromStorage() async {
    if (_currentUserId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString('${notificationsKey}_$_currentUserId');

      if (notificationsString != null) {
        final List<dynamic> notificationsJson = jsonDecode(notificationsString);
        _notifications.clear();
        _notifications.addAll(
            notificationsJson.map((json) => NotificationModel.fromJson(json)).toList()
        );
        debugPrint('✅ Notificaciones cargadas: ${_notifications.length}');
      }
    } catch (e) {
      debugPrint('❌ Error cargando notificaciones: $e');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Firebase Service already initialized');
      return;
    }

    try {
      await _initializeLocalNotifications();
      await _requestPermissions();
      await _getDeviceToken();
      _setupMessageHandlers();

      // ✅ CARGAR: Notificaciones persistidas al inicializar
      _currentUserId = await _getCurrentUserId();
      if (_currentUserId != null) {
        await _loadNotificationsFromStorage();
      }

      _isInitialized = true;
      debugPrint('✅ Firebase Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Service: $e');
    }
  }

  Future<void> onUserLoggedIn(String userId) async {
    debugPrint('👤 User logged in: $userId');

    // Guardar el ID del usuario actual
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
    _currentUserId = userId;

    // ✅ CARGAR: Notificaciones del usuario desde storage
    await _loadNotificationsFromStorage();

    // Limpiar mensajes procesados al cambiar de usuario
    _processedMessages.clear();

    // Enviar el token del dispositivo para este usuario
    if (_deviceToken != null) {
      await _sendTokenToServer();
    }

    debugPrint('✅ Usuario configurado con ${_notifications.length} notificaciones');
  }

  Future<void> onUserLoggedOut() async {
    debugPrint('👋 User logged out');

    // Remover el token del servidor antes de limpiar
    if (_deviceToken != null && _currentUserId != null) {
      await _removeTokenFromServer();
    }

    // ✅ GUARDAR: Notificaciones antes del logout
    await _saveNotificationsToStorage();

    // Limpiar datos locales
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
    _currentUserId = null;

    _notifications.clear();
    _processedMessages.clear();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const androidChannel = AndroidNotificationChannel(
      'nutrition_channel',
      'Nutrition Notifications',
      description: 'Notificaciones de planes nutricionales',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _getDeviceToken() async {
    try {
      _deviceToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_deviceToken');

      // Solo enviar al servidor si hay un usuario logueado
      _currentUserId = await _getCurrentUserId();
      if (_deviceToken != null && _currentUserId != null) {
        await _sendTokenToServer();
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        debugPrint('Token refreshed: $newToken');

        if (_deviceToken != newToken && _currentUserId != null) {
          await _removeTokenFromServer();
          _deviceToken = newToken;
          await _sendTokenToServer();
        } else {
          _deviceToken = newToken;
        }
      });
    } catch (e) {
      debugPrint('Error getting device token: $e');
    }
  }

  Future<void> _sendTokenToServer() async {
    if (_deviceToken == null || _currentUserId == null) {
      debugPrint('Missing device token or user ID, skipping token sync');
      return;
    }

    final token = await _getToken();
    if (token == null) {
      debugPrint('No auth token found, skipping device token sync');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'deviceToken': _deviceToken,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('✅ Device token sent to server successfully for user: $_currentUserId');
      } else {
        debugPrint('❌ Error sending device token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error sending device token to server: $e');
    }
  }

  Future<void> _removeTokenFromServer() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/notifications/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Device token removed from server successfully');
      } else {
        debugPrint('❌ Error removing device token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error removing device token from server: $e');
    }
  }

  void _setupMessageHandlers() {
    // ✅ FOREGROUND: Mensajes recibidos cuando la app está abierta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final messageId = message.messageId;
      debugPrint('📱 Received foreground message: $messageId');

      if (messageId != null && _processedMessages.contains(messageId)) {
        debugPrint('⚠️ Message already processed: $messageId');
        return;
      }

      if (messageId != null) {
        _processedMessages.add(messageId);
      }

      _handleMessage(message, true);
    });

    // ✅ BACKGROUND: App abierta desde notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageId = message.messageId;
      debugPrint('🔄 App opened from notification: $messageId');

      if (messageId != null && _processedMessages.contains(messageId)) {
        debugPrint('⚠️ Message already processed: $messageId');
        return;
      }

      if (messageId != null) {
        _processedMessages.add(messageId);
      }

      _handleMessage(message, false);
    });

    // ✅ TERMINATED: App iniciada desde notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final messageId = message.messageId;
        debugPrint('🚀 App opened from terminated state: $messageId');

        if (messageId != null && _processedMessages.contains(messageId)) {
          debugPrint('⚠️ Message already processed: $messageId');
          return;
        }

        if (messageId != null) {
          _processedMessages.add(messageId);
        }

        _handleMessage(message, false);
      }
    });
  }

  void _handleMessage(RemoteMessage message, bool showLocalNotification) {
    // ✅ VALIDAR: Solo procesar si hay usuario logueado
    if (_currentUserId == null) {
      debugPrint('⚠️ No user logged in, ignoring notification');
      return;
    }

    debugPrint('📨 Processing message for user: $_currentUserId');

    final notification = NotificationModel.fromFirebaseMessage(message);

    // ✅ AGREGAR: Notificación a la lista
    _notifications.insert(0, notification);

    // ✅ PERSISTIR: Guardar inmediatamente
    _saveNotificationsToStorage();

    // ✅ NOTIFICAR: A los listeners
    _notificationController.add(notification);

    debugPrint('✅ Notification added. Total: ${_notifications.length}');

    if (showLocalNotification) {
      _showLocalNotification(notification);
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const androidDetails = AndroidNotificationDetails(
      'nutrition_channel',
      'Nutrition Notifications',
      channelDescription: 'Notificaciones de planes nutricionales',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notification = NotificationModel.fromJson(data);
        _handleNotificationNavigation(notification);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNotificationNavigation(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.planApproved:
      case NotificationType.planRejected:
        debugPrint('Navigate to plan details: ${notification.planId}');
        break;
      default:
        debugPrint('Unknown notification type: ${notification.type}');
    }
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      // ✅ PERSISTIR: Cambios inmediatamente
      _saveNotificationsToStorage();
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
      // ✅ PERSISTIR: Solo si hubo cambios
      _saveNotificationsToStorage();
    }
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void clearAll() {
    _notifications.clear();
    _processedMessages.clear();
    // ✅ PERSISTIR: Limpiar storage también
    _saveNotificationsToStorage();
  }

  // ✅ NUEVO: Método para eliminar una notificación específica
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      _saveNotificationsToStorage();
    }
  }

  void dispose() {
    _notificationController.close();
  }
}