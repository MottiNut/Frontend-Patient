import 'package:frontendpatient/nutrition_plan/domain/models/meal_type_mapper.dart';

class Meal {
  final String type;
  final String name;
  final String description;
  final String ingredients;
  final int calories;
  final String preparationTime;

  Meal({
    required this.type,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.preparationTime,
  });

  // Método para obtener el label del tipo de comida
  String get typeLabel => MealTypeMapper.toLabel(type);
}