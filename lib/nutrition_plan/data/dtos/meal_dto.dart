import 'package:frontendpatient/nutrition_plan/domain/models/meal.dart';

class MealDto {
  final String type;
  final String name;
  final String description;
  final String ingredients;
  final int calories;
  final String preparationTime;

  MealDto({
    required this.type,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.preparationTime,
  });

  factory MealDto.fromJson(Map<String, dynamic> json) {
    return MealDto(
      type: json['type'],
      name: json['name'],
      description: json['description'],
      ingredients: json['ingredients'],
      calories: json['calories'],
      preparationTime: json['preparation_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'calories': calories,
      'preparation_time': preparationTime,
    };
  }

  // Convertir DTO a modelo de dominio
  Meal toDomain() {
    return Meal(
      type: type,
      name: name,
      description: description,
      ingredients: ingredients,
      calories: calories,
      preparationTime: preparationTime,
    );
  }
}