class Meal {
  final String type;
  final String name;
  final String description;
  final String ingredients;
  final String preparationTime;
  final int calories;

  const Meal({
    required this.type,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.calories,
    required this.preparationTime,
  });
}