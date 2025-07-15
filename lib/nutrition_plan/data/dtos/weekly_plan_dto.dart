import 'package:frontendpatient/nutrition_plan/data/dtos/daily_plan_dto.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/weekly_plan.dart';

class WeeklyPlanDto {
  final int planId;
  final String weekStartDate;
  final String weekEndDate;
  final String goal;
  final int energyRequirement;
  final List<DailyPlanDto> dailyPlans;
  final String? reviewNotes;

  WeeklyPlanDto({
    required this.planId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.goal,
    required this.energyRequirement,
    required this.dailyPlans,
    this.reviewNotes,
  });

  factory WeeklyPlanDto.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanDto(
      planId: json['planId'],
      weekStartDate: json['weekStartDate'],
      weekEndDate: json['weekEndDate'],
      goal: json['goal'],
      energyRequirement: json['energyRequirement'],
      dailyPlans: (json['dailyPlans'] as List)
          .map((plan) => DailyPlanDto.fromJson(plan))
          .toList(),
      reviewNotes: json['reviewNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'weekStartDate': weekStartDate,
      'weekEndDate': weekEndDate,
      'goal': goal,
      'energyRequirement': energyRequirement,
      'dailyPlans': dailyPlans.map((plan) => plan.toJson()).toList(),
      'reviewNotes': reviewNotes,
    };
  }

  // Convertir DTO a modelo de dominio
  WeeklyPlan toDomain() {
    return WeeklyPlan(
      planId: planId,
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
      goal: goal,
      energyRequirement: energyRequirement,
      dailyPlans: dailyPlans.map((plan) => plan.toDomain()).toList(),
      reviewNotes: reviewNotes,
    );
  }
}