// core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/models/plan_detail.dart';
import 'package:frontendpatient/screens/meal/meal_detail_screen.dart';
import 'package:frontendpatient/screens/recipes/recipes_screen.dart';
import 'package:provider/provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../providers/auth_provider.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterFlow(),
          settings: settings,
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const PatientHomeScreen(),
          settings: settings,
        );

      case RouteNames.mealDetail:
        final mealDetail = settings.arguments as PlanDetailResponse;
        return MaterialPageRoute(
          builder: (context) => MealDetailScreen(mealDetail: mealDetail),
        );

      case RouteNames.recipes:
        return MaterialPageRoute(
          builder: (_) => const RecipeScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundScreen(),
          settings: settings,
        );
    }
  }

  // Widget para manejar la ruta inicial basada en el estado de autenticación
  static Widget initialRoute() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const _LoadingScreen();
        }

        if (authProvider.isAuthenticated) {
          return const PatientHomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

// Pantalla de carga
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Pantalla de error 404
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}