// models/meal.dart
class Meal {
  final int? mealId;
  final String name;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final DateTime creationDate;

  Meal({
    this.mealId,
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'meal_id': mealId,
      'name': name,
      'description': description,
      'calories': calories,
      'prep_time_minutes': prepTimeMinutes,
      'creation_date': creationDate.toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      mealId: map['meal_id'],
      name: map['name'],
      description: map['description'],
      calories: map['calories'],
      prepTimeMinutes: map['prep_time_minutes'],
      creationDate: DateTime.parse(map['creation_date']),
    );
  }
}
