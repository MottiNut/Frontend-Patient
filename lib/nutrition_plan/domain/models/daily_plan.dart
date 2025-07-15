import 'package:frontendpatient/nutrition_plan/domain/models/meal.dart';

class DailyPlan {
  final String date;
  final String dayName;
  final List<Meal> meals;
  final int totalCalories;
  final Map<String, num> macronutrients;

  DailyPlan({
    required this.date,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.macronutrients,
  });

  // Método para obtener comidas por tipo
  List<Meal> getMealsByType(String type) {
    return meals.where((meal) => meal.type == type).toList();
  }

  // Método para obtener comida por tipo específico
  Meal? getMealByType(String type) {
    try {
      return meals.firstWhere((meal) => meal.type == type);
    } catch (e) {
      return null;
    }
  }
}