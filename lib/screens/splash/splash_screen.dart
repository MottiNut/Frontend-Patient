import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../../commons/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _retryCount = 0;
  bool _hasNavigated = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _initializeNotifications();
    _checkAndNavigate();
  }

  void _initializeLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Tapped on notification: ${response.payload}');
      },
    );
  }

  Future<void> _initializeNotifications() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _checkAndNavigate() async {
    // Verificar conectividad
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _retryCount++;
      if (_retryCount < 3) {
        _showNoInternetDialog();
      } else {
        exit(0);
      }
      return;
    }

    // Esperar 2 segundos para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted || _hasNavigated) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _hasNavigated = true;

      if (authProvider.isAuthenticated) {
        debugPrint('✅ Usuario autenticado → home');
        Navigator.pushReplacementNamed(context, '/button_navigation');
      } else {
        debugPrint('🔐 No autenticado → login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showNoInternetDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        title: Text(
          'Sin Conexión de Internet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.errorIcon,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: AppColors.errorIcon, size: 50),
            SizedBox(height: 20),
            Text(
              'Por favor, verifica tu conexión a internet e intenta nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkAndNavigate();
            },
            style: TextButton.styleFrom(
              side: BorderSide(color: AppColors.mainOrange, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: Text(
              'Reintentar',
              style: TextStyle(fontSize: 18, color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.mainOrange,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColors.mainOrange,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.mainOrange,
        body: Center(
          child: Image.asset('assets/images/logo_icon.png'),
        ),
      ),
    );
  }
}