class MealDataDto {
  final String mealType;
  final String mealTypeLabel;
  final String name;
  final String? description;
  final int? calories;
  final String? ingredients;
  final String? preparationTime;

  MealDataDto({
    required this.mealType,
    required this.mealTypeLabel,
    required this.name,
    this.description,
    this.calories,
    this.ingredients,
    this.preparationTime,
  });

  factory MealDataDto.fromJson(Map<String, dynamic> json) {
    return MealDataDto(
      mealType: json['mealType'],
      mealTypeLabel: json['mealTypeLabel'],
      name: json['name'],
      description: json['description'],
      calories: json['calories'],
      ingredients: json['ingredients'],
      preparationTime: json['preparationTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'mealTypeLabel': mealTypeLabel,
      'name': name,
      'description': description,
      'calories': calories,
      'ingredients': ingredients,
      'preparationTime': preparationTime,
    };
  }
}