import '../models/daily_plan.dart';
import '../repositories/nutrition_plan_repository.dart';

class GetTodayPlanUseCase {
  final NutritionPlanRepository repository;

  GetTodayPlanUseCase(this.repository);

  Future<DailyPlan> call() async {
    return await repository.getTodayPlan();
  }
}