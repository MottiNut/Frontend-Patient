

import 'package:frontendpatient/models/plan_detail.dart';

class NutritionPlanCreate {
  final int patientUserId;
  final String weekStartDate; // YYYY-MM-DD
  final int energyRequirement;
  final String? goal;
  final String? notes;
  final List<PlanDetailCreate> planDetails;

  NutritionPlanCreate({
    required this.patientUserId,
    required this.weekStartDate,
    required this.energyRequirement,
    this.goal,
    this.notes,
    required this.planDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_user_id': patientUserId,
      'week_start_date': weekStartDate,
      'energy_requirement': energyRequirement,
      'goal': goal,
      'notes': notes,
      'plan_details': planDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  // Validación de detalles del plan
  bool get hasValidPlanDetails => planDetails.isNotEmpty;

  // Verificar duplicados
  bool get hasNoDuplicates {
    final combinations = <String>{};
    for (final detail in planDetails) {
      final combination = '${detail.dayOfWeek}_${detail.mealType}';
      if (combinations.contains(combination)) {
        return false;
      }
      combinations.add(combination);
    }
    return true;
  }
}

class NutritionPlanResponse {
  final int planId;
  final int nutritionistUserId;
  final int patientUserId;
  final String weekStartDate;
  final int energyRequirement;
  final String? goal;
  final String? notes;
  final String status;
  final String createdAt;

  NutritionPlanResponse({
    required this.planId,
    required this.nutritionistUserId,
    required this.patientUserId,
    required this.weekStartDate,
    required this.energyRequirement,
    this.goal,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory NutritionPlanResponse.fromJson(Map<String, dynamic> json) {
    return NutritionPlanResponse(
      planId: json['plan_id'],
      nutritionistUserId: json['nutritionist_user_id'],
      patientUserId: json['patient_user_id'],
      weekStartDate: json['week_start_date'],
      energyRequirement: json['energy_requirement'],
      goal: json['goal'],
      notes: json['notes'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}

class WeeklyPlanResponse {
  final NutritionPlanResponse planInfo;
  final Map<String, List<PlanDetailResponse>> dailyPlans;
  final Map<String, int> weeklyTotals;
  final Map<String, String>? patientInfo;

  WeeklyPlanResponse({
    required this.planInfo,
    required this.dailyPlans,
    required this.weeklyTotals,
    this.patientInfo,
  });

  factory WeeklyPlanResponse.fromJson(Map<String, dynamic> json) {
    final dailyPlansMap = <String, List<PlanDetailResponse>>{};
    final dailyPlansJson = json['daily_plans'] as Map<String, dynamic>;

    for (final entry in dailyPlansJson.entries) {
      final dayPlans = (entry.value as List)
          .map((item) => PlanDetailResponse.fromJson(item))
          .toList();
      dailyPlansMap[entry.key] = dayPlans;
    }

    return WeeklyPlanResponse(
      planInfo: NutritionPlanResponse.fromJson(json['plan_info']),
      dailyPlans: dailyPlansMap,
      weeklyTotals: Map<String, int>.from(json['weekly_totals']),
      patientInfo: json['patient_info'] != null
          ? Map<String, String>.from(json['patient_info'])
          : null,
    );
  }
}

class DailyPlanResponse {
  final String date;
  final int dayOfWeek;
  final String dayName;
  final List<PlanDetailResponse> meals;
  final Map<String, int> dailyTotals;
  final String? message;

  DailyPlanResponse({
    required this.date,
    required this.dayOfWeek,
    required this.dayName,
    required this.meals,
    required this.dailyTotals,
    this.message,
  });

  factory DailyPlanResponse.fromJson(Map<String, dynamic> json) {
    return DailyPlanResponse(
      date: json['date'],
      dayOfWeek: json['day_of_week'],
      dayName: json['day_name'],
      meals: (json['meals'] as List)
          .map((item) => PlanDetailResponse.fromJson(item))
          .toList(),
      dailyTotals: Map<String, int>.from(json['daily_totals']),
      message: json['message'],
    );
  }
}