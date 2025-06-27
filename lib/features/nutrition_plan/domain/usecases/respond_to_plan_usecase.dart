import '../models/patient_response_request.dart';
import '../repositories/nutrition_plan_repository.dart';

class RespondToPlanUseCase {
  final NutritionPlanRepository repository;

  RespondToPlanUseCase(this.repository);

  Future<String> call(int planId, PatientResponseRequest request) async {
    return await repository.respondToPlan(planId, request);
  }
}