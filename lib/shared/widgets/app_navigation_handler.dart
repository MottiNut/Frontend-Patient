// shared/widgets/app_navigation_handler.dart
import 'package:flutter/material.dart';
import '../../core/routes/route_names.dart';

class AppNavigationHandler {
  static int _currentIndex = 0;

  static int get currentIndex => _currentIndex;

  static void resetToHome() {
    _currentIndex = 0;
  }

  static void setCurrentIndex(int index) {
    _currentIndex = index.clamp(0, 3);
  }

  // Método simplificado para usar con el SwipeNavigationWrapper
  static void handleNavigation(BuildContext context, int index) {
    _currentIndex = index.clamp(0, 3);

    // Ahora la navegación se maneja dentro del SwipeNavigationWrapper
    // Solo necesitas navegar a la ruta principal con el índice correcto
    String routeName = _getRouteNameFromIndex(index);
    Navigator.pushReplacementNamed(context, routeName);
  }

  static String _getRouteNameFromIndex(int index) {
    switch (index) {
      case 0:
        return RouteNames.home;
      case 1:
        return RouteNames.recipes;
      case 2:
        return RouteNames.pendingPlans;
      case 3:
        return RouteNames.profile;
      default:
        return RouteNames.home;
    }
  }

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