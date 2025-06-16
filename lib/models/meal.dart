class MealCreate {
  final String name;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final String? ingredients;
  final String? instructions;

  MealCreate({
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    this.ingredients,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'prep_time_minutes': prepTimeMinutes,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}
class MealResponse {
  final int mealId;
  final String name;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final String? ingredients;
  final String? instructions;
  final String createdAt;

  MealResponse({
    required this.mealId,
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    this.ingredients,
    this.instructions,
    required this.createdAt,
  });

  factory MealResponse.fromJson(Map<String, dynamic> json) {
    return MealResponse(
      mealId: json['meal_id'],
      name: json['name'],
      description: json['description'],
      calories: json['calories'],
      prepTimeMinutes: json['prep_time_minutes'],
      ingredients: json['ingredients'],
      instructions: json['instructions'],
      createdAt: json['created_at'],
    );
  }
}

class MealInPlan {
  final String name;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final String? ingredients;
  final String? instructions;

  MealInPlan({
    required this.name,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    this.ingredients,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'prep_time_minutes': prepTimeMinutes,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }

  factory MealInPlan.fromJson(Map<String, dynamic> json) {
    return MealInPlan(
      name: json['name'],
      description: json['description'],
      calories: json['calories'],
      prepTimeMinutes: json['prep_time_minutes'],
      ingredients: json['ingredients'],
      instructions: json['instructions'],
    );
  }
}