import '../../domain/models/weekly_plan.dart';
import 'daily_plan_entity.dart';

class WeeklyPlanEntity {
  final int planId;
  final String weekStartDate;
  final String weekEndDate;
  final String goal;
  final int energyRequirement;
  final List<DailyPlanEntity> dailyPlans;
  final String? reviewNotes;

  const WeeklyPlanEntity({
    required this.planId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.goal,
    required this.energyRequirement,
    required this.dailyPlans,
    this.reviewNotes,
  });

  factory WeeklyPlanEntity.fromJson(Map<String, dynamic> json) =>
      WeeklyPlanEntity(
        planId: json['plan_id'],
        weekStartDate: json['week_start_date'],
        weekEndDate: json['week_end_date'],
        goal: json['goal'],
        energyRequirement: json['energy_requirement'],
        dailyPlans: (json['daily_plans'] as List)
            .map((e) => DailyPlanEntity.fromJson(e))
            .toList(),
        reviewNotes: json['review_notes'],
      );

  Map<String, dynamic> toJson() => {
    'plan_id': planId,
    'week_start_date': weekStartDate,
    'week_end_date': weekEndDate,
    'goal': goal,
    'energy_requirement': energyRequirement,
    'daily_plans': dailyPlans.map((plan) => plan.toJson()).toList(),
    'review_notes': reviewNotes,
  };

  WeeklyPlan toDomain() => WeeklyPlan(
    planId: planId,
    weekStartDate: weekStartDate,
    weekEndDate: weekEndDate,
    goal: goal,
    energyRequirement: energyRequirement,
    dailyPlans: dailyPlans.map((plan) => plan.toDomain()).toList(),
    reviewNotes: reviewNotes,
  );
}