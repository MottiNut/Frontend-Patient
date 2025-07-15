// utils/meal_type_utils.dart
import 'package:flutter/material.dart';

class MealTypeUtils {
  static String getMealTypeLabel(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'Desayuno';
      case 'snack_morning':
        return 'Snack Mañana';
      case 'lunch':
        return 'Almuerzo';
      case 'snack_afternoon':
        return 'Snack Tarde';
      case 'dinner':
        return 'Cena';
      case 'snack_evening':
        return 'Snack Noche';
      default:
        return mealType;
    }
  }

  static IconData getMealTypeIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'snack_morning':
        return Icons.coffee;
      case 'lunch':
        return Icons.restaurant;
      case 'snack_afternoon':
        return Icons.cookie;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack_evening':
        return Icons.nightlight_round;
      default:
        return Icons.restaurant_menu;
    }
  }
}