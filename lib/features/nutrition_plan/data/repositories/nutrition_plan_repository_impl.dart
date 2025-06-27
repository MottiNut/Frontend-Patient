import '../../domain/repositories/nutrition_plan_repository.dart';
import '../../domain/models/daily_plan.dart';
import '../../domain/models/weekly_plan.dart';
import '../../domain/models/pending_acceptance.dart';
import '../../domain/models/patient_response_request.dart';
import '../datasources/nutrition_plan_remote_datasource.dart';
import '../datasources/nutrition_plan_local_datasource.dart';

class NutritionPlanRepositoryImpl implements NutritionPlanRepository {
  final NutritionPlanRemoteDataSource remoteDataSource;
  final NutritionPlanLocalDataSource localDataSource;

  NutritionPlanRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<PendingAcceptance>> getPendingAcceptancePlans() async {
    try {
      final entities = await remoteDataSource.getPendingAcceptancePlans();
      return entities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Error obteniendo planes pendientes: $e');
    }
  }

  @override
  Future<String> respondToPlan(int planId, PatientResponseRequest request) async {
    try {
      final requestMap = {
        'action': request.action.value,
        'feedback': request.feedback,
      };
      return await remoteDataSource.respondToPlan(planId, requestMap);
    } catch (e) {
      throw Exception('Error respondiendo al plan: $e');
    }
  }

  @override
  Future<DailyPlan> getTodayPlan() async {
    try {
      final entity = await remoteDataSource.getTodayPlan();
      return entity.toDomain();
    } catch (e) {
      throw Exception('Error obteniendo plan de hoy: $e');
    }
  }

  @override
  Future<DailyPlan> getDayPlan(int dayNumber, {String? date}) async {
    try {
      final entity = await remoteDataSource.getDayPlan(dayNumber, date: date);
      return entity.toDomain();
    } catch (e) {
      throw Exception('Error obteniendo plan del día: $e');
    }
  }

  @override
  Future<WeeklyPlan> getWeeklyPlan({String? date}) async {
    try {
      final entity = await remoteDataSource.getWeeklyPlan(date: date);
      return entity.toDomain();
    } catch (e) {
      throw Exception('Error obteniendo plan semanal: $e');
    }
  }

  @override
  Future<List<WeeklyPlan>> getPlanHistory() async {
    try {
      final entities = await remoteDataSource.getPlanHistory();
      return entities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      throw Exception('Error obteniendo historial de planes: $e');
    }
  }
}