import 'package:flutter/material.dart';
import 'package:frontendpatient/screens/recipes/recipes_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/pending-plans/pending_plans_screen.dart';
import '../../screens/profile/profile_screen.dart';
import 'route_names.dart';

class AppRouter {
  // Mapa de rutas para mejor rendimiento
  static final Map<String, Widget Function(BuildContext)> _routes = {
    RouteNames.login: (_) => const LoginScreen(),
    RouteNames.register: (_) => const RegisterFlow(),
    RouteNames.home: (_) => const PatientHomeScreen(),
    RouteNames.recipes: (_) => const RecipesScreen(),
    RouteNames.pendingPlans: (_) => const PendingPlansScreen(),
    RouteNames.profile: (_) => const ProfileScreen(),
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

  // Método auxiliar para crear rutas con configuración consistente
  static Route<dynamic> _createRoute(
      Widget Function(BuildContext) builder,
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }

  // Método para rutas con animaciones personalizadas (opcional)
  static Route<dynamic> _createAnimatedRoute(
      Widget Function(BuildContext) builder,
      RouteSettings settings, {
        Duration duration = const Duration(milliseconds: 300),
      }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

// Pantalla optimizada para rutas no encontradas
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
                // Navegar al home o hacer pop
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, RouteNames.home);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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