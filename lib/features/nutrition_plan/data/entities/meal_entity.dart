import '../../domain/models/meal.dart';

class MealEntity {
  final String type;
  final String name;
  final String description;
  final String ingredients;
  final String preparationTime;
  final int calories;

  const MealEntity({
    required this.type,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.preparationTime,
  });

  factory MealEntity.fromJson(Map<String, dynamic> json) => MealEntity(
    type: json['type'],
    name: json['name'],
    description: json['description'],
    ingredients: json['ingredients'],
    calories: json['calories'],
    preparationTime: json['preparation_time'],
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'ingredients': ingredients,
    'calories': calories,
    'preparation_time': preparationTime,
  };

  Meal toDomain() => Meal(
    type: type,
    name: name,
    description: description,
    ingredients: ingredients,
    calories: calories,
    preparationTime: preparationTime,
  );
}