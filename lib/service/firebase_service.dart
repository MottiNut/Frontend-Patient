import 'dart:convert';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontendpatient/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _deviceToken;
  final List<NotificationModel> _notifications = [];
  static const String tokenKey = 'auth_token';

  // ✅ Control de duplicados
  final Set<String> _processedMessages = <String>{};
  bool _isInitialized = false;

  // Configura tu URL base del backend aquí
  static const String _baseUrl = 'http://10.0.2.2:5000';

  // Obtener token desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  Stream<NotificationModel> get onNotificationReceived => _notificationController.stream;
  final _notificationController = StreamController<NotificationModel>.broadcast();

  Future<void> initialize() async {
    // ✅ Prevenir múltiples inicializaciones
    if (_isInitialized) {
      debugPrint('Firebase Service already initialized');
      return;
    }

    try {
      // ❌ NO inicializar Firebase aquí - ya se hizo en main.dart
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      await _initializeLocalNotifications();
      await _requestPermissions();
      await _getDeviceToken();
      _setupMessageHandlers();

      _isInitialized = true;
      debugPrint('Firebase Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Service: $e');
    }
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

    // Crear canal de notificación para Android
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

      if (_deviceToken != null) {
        await _sendTokenToServer();
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _deviceToken = newToken;
        _sendTokenToServer();
      });
    } catch (e) {
      debugPrint('Error getting device token: $e');
    }
  }

  Future<void> _sendTokenToServer() async {
    if (_deviceToken == null) return;

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

      if (response.statusCode == 200) {
        debugPrint('Device token sent to server successfully');
      } else {
        debugPrint('Error sending device token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending device token to server: $e');
    }
  }

  void _setupMessageHandlers() {
    // ✅ Mensaje recibido cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final messageId = message.messageId;
      debugPrint('Received foreground message: $messageId');

      // ✅ Control de duplicados
      if (messageId != null && _processedMessages.contains(messageId)) {
        debugPrint('Message already processed: $messageId');
        return;
      }

      if (messageId != null) {
        _processedMessages.add(messageId);
      }

      _handleMessage(message, true);
    });

    // ✅ App abierta desde notificación (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageId = message.messageId;
      debugPrint('App opened from notification: $messageId');

      // ✅ Control de duplicados
      if (messageId != null && _processedMessages.contains(messageId)) {
        debugPrint('Message already processed: $messageId');
        return;
      }

      if (messageId != null) {
        _processedMessages.add(messageId);
      }

      _handleMessage(message, false);
    });

    // ✅ App abierta desde notificación (terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final messageId = message.messageId;
        debugPrint('App opened from terminated state: $messageId');

        // ✅ Control de duplicados
        if (messageId != null && _processedMessages.contains(messageId)) {
          debugPrint('Message already processed: $messageId');
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
    final notification = NotificationModel.fromFirebaseMessage(message);
    _notifications.insert(0, notification);
    _notificationController.add(notification);

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
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void clearAll() {
    _notifications.clear();
    _processedMessages.clear(); // ✅ Limpiar también los mensajes procesados
  }

  void dispose() {
    _notificationController.close();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling background message: ${message.messageId}');
}