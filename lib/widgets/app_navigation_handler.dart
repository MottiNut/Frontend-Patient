// lib/core/navigation/app_navigation_handler.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/route_names.dart';

class AppNavigationHandler {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void handleNavigation(BuildContext context, int index) {
    _currentIndex = index;

    switch (index) {
      case 0:
        Navigator.pushNamed(context, RouteNames.home);
        break;
      case 1:
      // Navegar a Recetas
        Navigator.pushNamed(context, RouteNames.recipes);
        break;
      case 2:
      // Navegar a Perfil
        Navigator.pushNamed(context, RouteNames.profile);
        break;
      default:
        break;
    }
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
  }

  // Método para navegación programática
  void navigateToHome(BuildContext context) {
    _currentIndex = 0;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
          (route) => false,
    );
  }

  void navigateToRecipes(BuildContext context) {
    _currentIndex = 1;
    Navigator.pushNamed(context, RouteNames.recipes);
  }

  void navigateToProfile(BuildContext context) {
    _currentIndex = 2;
    Navigator.pushNamed(context, RouteNames.profile);
  }

  // Método para manejar el back button en diferentes pantallas
  bool handleBackNavigation(BuildContext context, int currentScreenIndex) {
    if (currentScreenIndex != 0) {
      navigateToHome(context);
      return false; // Previene el pop por defecto
    }
    return true; // Permite el pop por defecto
  }
}