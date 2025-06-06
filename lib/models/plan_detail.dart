// lib/models/plan_detail.dart
import 'package:frontendpatient/models/meal.dart';

class PlanDetail {
  final int detailId;
  final int nutritionPlanId;
  final String mealType;
  final String description;
  final String creationDate;
  final Meal meal;

  PlanDetail({
    required this.detailId,
    required this.nutritionPlanId,
    required this.mealType,
    required this.description,
    required this.creationDate,
    required this.meal,
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    return PlanDetail(
      detailId: json['detail_id'] ?? 0,
      nutritionPlanId: json['nutrition_plan_id'] ?? 0,
      mealType: json['meal_type'] ?? '',
      description: json['description'] ?? '',
      creationDate: json['creation_date'] ?? '',
      meal: Meal.fromJson(json['meal'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId,
      'nutrition_plan_id': nutritionPlanId,
      'meal_type': mealType,
      'description': description,
      'creation_date': creationDate,
      'meal': meal.toJson(),
    };
  }
}

class PlanDetailCreate {
  final int nutritionPlanId;
  final String mealType;
  final String description;
  final int mealsMealId;

  PlanDetailCreate({
    required this.nutritionPlanId,
    required this.mealType,
    required this.description,
    required this.mealsMealId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nutrition_plan_id': nutritionPlanId,
      'meal_type': mealType,
      'description': description,
      'meals_meal_id': mealsMealId,
    };
  }
}