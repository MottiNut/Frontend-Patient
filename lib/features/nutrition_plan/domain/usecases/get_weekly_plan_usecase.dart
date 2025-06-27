import '../models/weekly_plan.dart';
import '../repositories/nutrition_plan_repository.dart';

class GetWeeklyPlanUseCase {
  final NutritionPlanRepository repository;

  GetWeeklyPlanUseCase(this.repository);

  Future<WeeklyPlan> call({String? date}) async {
    return await repository.getWeeklyPlan(date: date);
  }
}
