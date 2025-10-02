import 'package:flutter/material.dart';
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
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProxyProvider<NotificationProvider, AuthProvider>(
          create: (context) => AuthProvider(),
          update: (context, notificationProvider, authProvider) {
            authProvider ??= AuthProvider();
            authProvider.setNotificationProvider(notificationProvider);
            return authProvider;
          },
        ),
      ],
      // NO USAR Consumer AQUÍ - Causa reconstrucciones innecesarias
      child: MaterialApp(
        title: 'Mottinutt Patient',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: RouteNames.splash, // SOLO SE USA UNA VEZ
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}