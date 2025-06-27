import '../models/weekly_plan.dart';
import '../repositories/nutrition_plan_repository.dart';

class GetPlanHistoryUseCase {
  final NutritionPlanRepository repository;

  GetPlanHistoryUseCase(this.repository);

  Future<List<WeeklyPlan>> call() async {
    return await repository.getPlanHistory();
  }
}