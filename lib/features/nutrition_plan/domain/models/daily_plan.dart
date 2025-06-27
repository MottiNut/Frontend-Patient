import 'meal.dart';

class DailyPlan {
  final String date;
  final String dayName;
  final List<Meal> meals;
  final int totalCalories;
  final Map<String, num> macronutrients;

  const DailyPlan({
    required this.date,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.macronutrients,
  });
}