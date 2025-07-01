import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/app_wrapper.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:frontendpatient/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveedor de notificaciones independiente
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        // Proveedor de autenticación con inyección de dependencias mejorada
        ChangeNotifierProxyProvider<NotificationProvider, AuthProvider>(
          create: (context) => AuthProvider(),
          update: (context, notificationProvider, authProvider) {
            // Inyectar el proveedor de notificaciones de forma reactiva
            authProvider ??= AuthProvider();
            authProvider.setNotificationProvider(notificationProvider);
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
            home: const AppWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Consistencia en el tamaño de texto
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            // Navigator key para navegación programática si es necesario
            navigatorKey: GlobalKey<NavigatorState>(),
          );
        },
      ),
    );
  }
}