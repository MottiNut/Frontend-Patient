import 'daily_plan.dart';

class WeeklyPlan {
  final int planId;
  final String weekStartDate;
  final String weekEndDate;
  final String goal;
  final int energyRequirement;
  final List<DailyPlan> dailyPlans;
  final String? reviewNotes;

  const WeeklyPlan({
    required this.planId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.goal,
    required this.energyRequirement,
    required this.dailyPlans,
    this.reviewNotes,
  });
}