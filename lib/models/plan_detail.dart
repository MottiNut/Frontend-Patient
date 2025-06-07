// lib/models/plan_models.dart
import 'package:frontendpatient/models/meal.dart';

class PlanDetailCreate {
  final int dayOfWeek; // 1-7 (Lunes a Domingo)
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack_morning', etc.
  final MealInPlan meal;
  final String portionSize;
  final String? specialInstructions;

  PlanDetailCreate({
    required this.dayOfWeek,
    required this.mealType,
    required this.meal,
    this.portionSize = "1 porción",
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'meal_type': mealType,
      'meal': meal.toJson(),
      'portion_size': portionSize,
      'special_instructions': specialInstructions,
    };
  }

  // Validación de día de la semana
  bool get isValidDayOfWeek => dayOfWeek >= 1 && dayOfWeek <= 7;

  // Validación de tipo de comida
  bool get isValidMealType {
    const validTypes = [
      'breakfast',
      'snack_morning',
      'lunch',
      'snack_afternoon',
      'dinner',
      'snack_evening'
    ];
    return validTypes.contains(mealType);
  }
}

class PlanDetailResponse {
  final int detailId;
  final int dayOfWeek;
  final String dayName;
  final String mealType;
  final String mealTypeLabel;
  final String portionSize;
  final String? specialInstructions;
  final MealResponse meal;

  PlanDetailResponse({
    required this.detailId,
    required this.dayOfWeek,
    required this.dayName,
    required this.mealType,
    required this.mealTypeLabel,
    required this.portionSize,
    this.specialInstructions,
    required this.meal,
  });

  factory PlanDetailResponse.fromJson(Map<String, dynamic> json) {
    return PlanDetailResponse(
      detailId: json['detail_id'],
      dayOfWeek: json['day_of_week'],
      dayName: json['day_name'],
      mealType: json['meal_type'],
      mealTypeLabel: json['meal_type_label'],
      portionSize: json['portion_size'],
      specialInstructions: json['special_instructions'],
      meal: MealResponse.fromJson(json['meal']),
    );
  }
}