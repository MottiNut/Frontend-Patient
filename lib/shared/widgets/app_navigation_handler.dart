// lib/core/navigation/app_navigation_handler.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/route_names.dart';

class AppNavigationHandler {
  static int _currentIndex = 0;

  static int get currentIndex => _currentIndex;

  static void handleNavigation(BuildContext context, int index) {
    print('Navegando a índice: $index, actual: $_currentIndex'); // Debug
    if (_currentIndex == index) return;

    _currentIndex = index;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, RouteNames.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, RouteNames.recipes);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, RouteNames.pendingPlans);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, RouteNames.profile);
        break;
    }
  }

  static void setCurrentIndex(int index) {
    print('Estableciendo índice actual: $index'); // Debug
    _currentIndex = index;
  }

  // Método específico para navegar al perfil desde cualquier lugar
  static void navigateToProfile(BuildContext context) {
    _currentIndex = 3;
    Navigator.pushReplacementNamed(context, RouteNames.profile);
  }

  // Método específico para navegar al home desde cualquier lugar
  static void navigateToHome(BuildContext context) {
    _currentIndex = 0;
    Navigator.pushReplacementNamed(context, RouteNames.home);
  }

  // Para navegación inicial (después del login)
  static void navigateToHomeInitial(BuildContext context) {
    _currentIndex = 0;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
          (route) => false,
    );
  }

  // Método para obtener el índice basado en la ruta actual
  static int getIndexFromRoute(String routeName) {
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