import 'package:flutter/material.dart';
import 'package:frontendpatient/commons/routes/swipe_navigation_wrapper.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/screens/code_verificaction_screen.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../auth/presentation/screens/register_screen.dart';
import '../../screens/splash/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.splash: (_) => SplashScreen(),
    RouteNames.login: (_) => const LoginScreen(),
    RouteNames.register: (_) => const RegisterFlow(),
    RouteNames.home: (_) => const SwipeNavigationWrapper(initialIndex: 0),
    RouteNames.recipes: (_) => const SwipeNavigationWrapper(initialIndex: 1),
    RouteNames.pendingPlans: (_) => const SwipeNavigationWrapper(initialIndex: 2),
    RouteNames.profile: (_) => const SwipeNavigationWrapper(initialIndex: 3),
    RouteNames.initial: (_) => const SwipeNavigationWrapper(initialIndex: 0),
  };

  static Route? generateRoute(RouteSettings settings) {
    debugPrint('🧭 Navegando a: ${settings.name}');

    // Manejo de rutas con argumentos
    if (settings.name == RouteNames.codeVerification) {
      final args = settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        debugPrint('❌ No hay argumentos para verificación');
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      }

      return MaterialPageRoute(
        builder: (_) => CodeVerificationScreen(
          email: args['email'] as String,
          phone: args['phone'] as String?,
          verificationMethod: args['verificationMethod'] as VerificationMethod,
        ),
        settings: settings,
      );
    }

    final routeName = settings.name;
    final builder = routes[routeName];

    if (builder != null) {
      return createRoute(builder, settings);
    }

    // Ruta por defecto
    debugPrint('⚠️ Ruta no encontrada: $routeName');
    return createRoute(
          (_) => const NotFoundScreen(),
      settings,
    );
  }

  static Route createRoute(
      WidgetBuilder builder,
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

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
                Navigator.pushReplacementNamed(context, RouteNames.login);
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