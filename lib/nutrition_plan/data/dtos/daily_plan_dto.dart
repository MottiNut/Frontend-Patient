import 'package:frontendpatient/nutrition_plan/data/dtos/meal_dto.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/daily_plan.dart';

class DailyPlanDto {
  final String date;
  final String dayName;
  final List<MealDto> meals;
  final int totalCalories;
  final Map<String, num> macronutrients;

  DailyPlanDto({
    required this.date,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.macronutrients,
  });

  factory DailyPlanDto.fromJson(Map<String, dynamic> json) {
    return DailyPlanDto(
      date: json['date'],
      dayName: json['dayName'],
      meals: (json['meals'] as List)
          .map((item) => MealDto.fromJson(item))
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

  // Convertir DTO a modelo de dominio
  DailyPlan toDomain() {
    return DailyPlan(
      date: date,
      dayName: dayName,
      meals: meals.map((meal) => meal.toDomain()).toList(),
      totalCalories: totalCalories,
      macronutrients: macronutrients,
    );
  }
}