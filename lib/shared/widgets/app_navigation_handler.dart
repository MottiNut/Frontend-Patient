// shared/widgets/app_navigation_handler.dart
import 'package:flutter/material.dart';
import '../../core/routes/route_names.dart';

class AppNavigationHandler {
  static int _currentIndex = 0; // Privado para controlar el acceso

  // Getter público
  static int get currentIndex => _currentIndex;

  // Método para resetear el índice (usar al cerrar sesión)
  static void resetToHome() {
    _currentIndex = 0;
  }

  // Método para establecer el índice manualmente
  static void setCurrentIndex(int index) {
    _currentIndex = index.clamp(0, 3);
  }

  // Método principal de navegación
  static void handleNavigation(BuildContext context, int index) {
    // Actualizar el índice actual
    _currentIndex = index.clamp(0, 3);

    switch (index) {
      case 0:
        _navigateToHome(context);
        break;
      case 1:
        _navigateToRecipes(context);
        break;
      case 2:
        _navigateToPending(context);
        break;
      case 3:
        _navigateToProfile(context);
        break;
      default:
        _navigateToHome(context);
        break;
    }
  }

  static void _navigateToHome(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != RouteNames.home) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    }
  }

  static void _navigateToRecipes(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != RouteNames.recipes) {
      Navigator.pushReplacementNamed(context, RouteNames.recipes);
    }
  }

  static void _navigateToPending(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != RouteNames.pendingPlans) {
      Navigator.pushReplacementNamed(context, RouteNames.pendingPlans);
    }
  }

  static void _navigateToProfile(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != RouteNames.profile) {
      Navigator.pushReplacementNamed(context, RouteNames.profile);
    }
  }

  // Método para obtener el índice basado en la ruta actual
  static int getIndexFromRoute(String? routeName) {
    switch (routeName) {
      case RouteNames.home:
        return 0;
      case RouteNames.recipes:
        return 1;
      case RouteNames.pendingPlans:
        return 2;
      case RouteNames.profile:
        return 3;
      default:
        return 0;
    }
  }
}