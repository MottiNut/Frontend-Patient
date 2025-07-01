class DailyPlanResponse {
  final String date;
  final String dayName;
  final List<Meal> meals;
  final int totalCalories;
  final Map<String, num> macronutrients;

  DailyPlanResponse({
    required this.date,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.macronutrients,
  });

  factory DailyPlanResponse.fromJson(Map<String, dynamic> json) {
    return DailyPlanResponse(
      date: json['date'],
      dayName: json['dayName'],
      meals: (json['meals'] as List)
          .map((item) => Meal.fromJson(item))
          .toList(),
      totalCalories: json['totalCalories'],
      macronutrients: Map<String, num>.from(json['macronutrients']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayName': dayName,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'totalCalories': totalCalories,
      'macronutrients': macronutrients,
    };
  }
}
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

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
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
}
