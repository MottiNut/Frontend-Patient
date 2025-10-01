import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/routes/app_wrapper.dart';
import 'package:frontendpatient/auth/presentation/providers/auth_provider.dart';
import 'package:frontendpatient/notification/presentation/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'commons/routes/route_names.dart';
import 'commons/themes/app_theme.dart';
import 'commons/routes/app_router.dart';

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
            title: 'Mottinutri Patient',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            navigatorKey: GlobalKey<NavigatorState>(),
          );

        },
      ),
    );
  }
}