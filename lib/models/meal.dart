// lib/models/meal.dart
class Meal {
  final int mealId;
  final String name;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final String creationDate;

  Meal({
    required this.mealId,
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    required this.creationDate,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealId: json['meal_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: json['calories'] ?? 0,
      prepTimeMinutes: json['prep_time_minutes'] ?? 0,
      creationDate: json['creation_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'name': name,
      'description': description,
      'calories': calories,
      'prep_time_minutes': prepTimeMinutes,
      'creation_date': creationDate,
    };
  }

  @override
  String toString() {
    return 'Meal{mealId: $mealId, name: $name, calories: $calories}';
  }
}

class MealCreate {
  final String name;
  final String description;
  final int calories;
  final int prepTimeMinutes;

  MealCreate({
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'prep_time_minutes': prepTimeMinutes,
    };
  }
}