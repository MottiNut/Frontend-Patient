import '../../domain/models/daily_plan.dart';
import 'meal_entity.dart';

class DailyPlanEntity {
  final String date;
  final String dayName;
  final List<MealEntity> meals;
  final int totalCalories;
  final Map<String, num> macronutrients;

  const DailyPlanEntity({
    required this.date,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.macronutrients,
  });

  factory DailyPlanEntity.fromJson(Map<String, dynamic> json) => DailyPlanEntity(
    date: json['date'],
    dayName: json['dayName'],
    meals: (json['meals'] as List).map((e) => MealEntity.fromJson(e)).toList(),
    totalCalories: json['totalCalories'],
    macronutrients: Map<String, num>.from(json['macronutrients']),
  );

  DailyPlan toDomain() => DailyPlan(
    date: date,
    dayName: dayName,
    meals: meals.map((m) => m.toDomain()).toList(),
    totalCalories: totalCalories,
    macronutrients: macronutrients,
  );
  Map<String, dynamic> toJson() => {
    'date': date,
    'dayName': dayName,
    'meals': meals.map((meal) => meal.toJson()).toList(),
    'totalCalories': totalCalories,
    'macronutrients': macronutrients,
  };
}