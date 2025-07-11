// core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/swipe_navigation_wrapper.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final Map<String, Widget Function(BuildContext)> _routes = {
    RouteNames.login: (_) => const LoginScreen(),
    RouteNames.register: (_) => const RegisterFlow(),
    // 🔥 ESTE ES EL CAMBIO IMPORTANTE:
    // RouteNames.home debe apuntar al SwipeNavigationWrapper, no al PatientHomeScreen
    RouteNames.home: (_) => const SwipeNavigationWrapper(initialIndex: 0),

    // Si necesitas acceso directo a secciones específicas:
    RouteNames.recipes: (_) => const SwipeNavigationWrapper(initialIndex: 1),
    RouteNames.pendingPlans: (_) => const SwipeNavigationWrapper(initialIndex: 2),
    RouteNames.profile: (_) => const SwipeNavigationWrapper(initialIndex: 3),

    // Ruta principal que también va al home
    '/main': (_) => const SwipeNavigationWrapper(initialIndex: 0),
    RouteNames.initial: (_) => const SwipeNavigationWrapper(initialIndex: 0),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final builder = _routes[routeName];

    if (builder != null) {
      return _createRoute(builder, settings);
    }

    // Ruta por defecto si no se encuentra
    return _createRoute(
          (_) => const _NotFoundScreen(),
      settings,
    );
  }

  static Route<dynamic> _createRoute(
      Widget Function(BuildContext) builder,
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, RouteNames.home);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}