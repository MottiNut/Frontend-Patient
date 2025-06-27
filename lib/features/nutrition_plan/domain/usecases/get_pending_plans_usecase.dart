import '../models/pending_acceptance.dart';
import '../repositories/nutrition_plan_repository.dart';

class GetPendingPlansUseCase {
  final NutritionPlanRepository repository;

  GetPendingPlansUseCase(this.repository);

  Future<List<PendingAcceptance>> call() async {
    return await repository.getPendingAcceptancePlans();
  }
}