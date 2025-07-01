// lib/app.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/app_wrapper.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:frontendpatient/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ NotificationProvider sin inicialización inmediata
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),

        // ✅ AuthProvider maneja toda la inicialización
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = AuthProvider();
            final notificationProvider = context.read<NotificationProvider>();

            // ✅ CONFIGURAR: Dependencia una sola vez
            authProvider.setNotificationProvider(notificationProvider);

            // ✅ INICIALIZAR: Todo desde AuthProvider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.initializeApp();
            });

            return authProvider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'NutriApp',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,

            // ✅ CLAVE: Usar AppWrapper como home Y configurar rutas
            home: const AppWrapper(),

            // ✅ CRÍTICO: Configurar rutas para navegación programática
            onGenerateRoute: AppRouter.generateRoute,

            // ✅ GLOBAL: Builder para escalado de texto
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child ?? const SizedBox.shrink(),
              );
            },

            // ✅ NAVEGACIÓN: Configurar navegación global
            navigatorKey: GlobalKey<NavigatorState>(),
          );
        },
      ),
    );
  }
}