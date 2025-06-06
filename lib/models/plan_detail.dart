// models/plan_detail.dart
enum MealType { breakfast, morningSnack, lunch, afternoonSnack, dinner }

class PlanDetail {
  final int? planDetailId;
  final int nutritionPlanId;
  final MealType mealType;
  final String description;
  final DateTime creationDate;
  final int mealId;

  PlanDetail({
    this.planDetailId,
    required this.nutritionPlanId,
    required this.mealType,
    required this.description,
    required this.creationDate,
    required this.mealId,
  });

  Map<String, dynamic> toMap() {
    return {
      'plan_detail_id': planDetailId,
      'nutrition_plan_id': nutritionPlanId,
      'meal_type': mealType.name,
      'description': description,
      'creation_date': creationDate.toIso8601String(),
      'meals_meal_id': mealId,
    };
  }

  factory PlanDetail.fromMap(Map<String, dynamic> map) {
    return PlanDetail(
      planDetailId: map['plan_detail_id'],
      nutritionPlanId: map['nutrition_plan_id'],
      mealType: MealType.values.firstWhere(
            (e) => e.name == map['meal_type'],
        orElse: () => MealType.breakfast,
      ),
      description: map['description'],
      creationDate: DateTime.parse(map['creation_date']),
      mealId: map['meals_meal_id'],
    );
  }
}
