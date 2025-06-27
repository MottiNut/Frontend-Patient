import '../models/daily_plan.dart';
import '../models/weekly_plan.dart';
import '../models/pending_acceptance.dart';
import '../models/patient_response_request.dart';

abstract class NutritionPlanRepository {
  Future<List<PendingAcceptance>> getPendingAcceptancePlans();
  Future<String> respondToPlan(int planId, PatientResponseRequest request);
  Future<DailyPlan> getTodayPlan();
  Future<DailyPlan> getDayPlan(int dayNumber, {String? date});
  Future<WeeklyPlan> getWeeklyPlan({String? date});
  Future<List<WeeklyPlan>> getPlanHistory();
}