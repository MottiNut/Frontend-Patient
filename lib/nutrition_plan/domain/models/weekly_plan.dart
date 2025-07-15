import 'package:frontendpatient/nutrition_plan/domain/models/daily_plan.dart';

class WeeklyPlan {
  final int planId;
  final String weekStartDate;
  final String weekEndDate;
  final String goal;
  final int energyRequirement;
  final List<DailyPlan> dailyPlans;
  final String? reviewNotes;

  WeeklyPlan({
    required this.planId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.goal,
    required this.energyRequirement,
    required this.dailyPlans,
    this.reviewNotes,
  });

  // Método para obtener plan de un día específico
  DailyPlan? getDayPlan(int dayNumber) {
    if (dayNumber >= 1 && dayNumber <= dailyPlans.length) {
      return dailyPlans[dayNumber - 1];
    }
    return null;
  }
}