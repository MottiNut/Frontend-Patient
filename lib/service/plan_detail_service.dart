// lib/services/plan_service.dart
import 'dart:convert';
import 'package:frontendpatient/models/nutrition_plan.dart';
import 'package:frontendpatient/models/user_model.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class PlanService {
  final ApiService _apiService = ApiService();

  /// Crear un plan nutricional completo (solo nutricionistas)
  Future<CreatePlanResponse> createNutritionPlan(
      NutritionPlanCreate planCreate) async {
    try {
      final response = await _apiService.post(
        '/nutrition-plans',
        body: planCreate.toJson(),
      );

      final data = json.decode(response.body);
      return CreatePlanResponse.fromJson(data);
    } catch (e) {
      throw PlanException('Error al crear plan nutricional: $e');
      
    }
  }

  /// Obtener planes creados por el nutricionista actual
  Future<List<NutritionistPlanResponse>> getNutritionistPlans() async {
    try {
      final response = await _apiService.get(
          '/nutrition-plans/my-created-plans');
      final List<dynamic> data = json.decode(response.body);

      return data
          .map((json) => NutritionistPlanResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw PlanException('Error al obtener planes del nutricionista: $e');
    }
  }

  /// Obtener plan semanal de un paciente específico (solo nutricionistas)
  Future<WeeklyPlanResponse> getPatientWeeklyPlan(int patientId, {
    String? weekStart,
  }) async {
    try {
      String endpoint = '/nutrition-plans/patient/$patientId/weekly';
      if (weekStart != null) {
        endpoint += '?week_start=$weekStart';
      }

      final response = await _apiService.get(endpoint);
      final data = json.decode(response.body);

      return WeeklyPlanResponse.fromJson(data);
    } catch (e) {
      throw PlanException('Error al obtener plan semanal del paciente: $e');
    }
  }

  /// Obtener un plan nutricional específico por ID
  Future<Map<String, dynamic>> getNutritionPlan(int planId) async {
    try {
      final response = await _apiService.get('/nutrition-plans/$planId');
      return json.decode(response.body);
    } catch (e) {
      throw PlanException('Error al obtener plan nutricional: $e');
    }
  }

  /// Obtener comidas del día actual (solo pacientes)
  Future<DailyPlanResponse> getTodayMeals() async {
    try {
      final response = await _apiService.get('/my-nutrition-plan/today');
      final data = json.decode(response.body);

      return DailyPlanResponse.fromJson(data);
    } catch (e) {
      throw PlanException('Error al obtener comidas de hoy: $e');
    }
  }

  /// Obtener comidas de un día específico (1-7) (solo pacientes)
  Future<DailyPlanResponse> getMealsByDay(int dayNumber) async {
    try {
      if (dayNumber < 1 || dayNumber > 7) {
        throw PlanException('El día debe estar entre 1 (Lunes) y 7 (Domingo)');
      }

      final response = await _apiService.get(
          '/my-nutrition-plan/day/$dayNumber');
      final data = json.decode(response.body);

      return DailyPlanResponse.fromJson(data);
    } catch (e) {
      throw PlanException('Error al obtener comidas del día: $e');
    }
  }

  /// Obtener plan semanal completo del paciente (solo pacientes)
  Future<WeeklyPlanResponse> getMyWeeklyPlan({String? weekStart}) async {
    try {
      String endpoint = '/my-nutrition-plan/weekly';
      if (weekStart != null) {
        endpoint += '?week_start=$weekStart';
      }

      final response = await _apiService.get(endpoint);
      final data = json.decode(response.body);

      return WeeklyPlanResponse.fromJson(data);
    } catch (e) {
      throw PlanException('Error al obtener mi plan semanal: $e');
    }
  }

  /// Obtener lista de pacientes (solo nutricionistas)
  Future<List<UserResponse>> getPatients() async {
    try {
      final response = await _apiService.get('/users/patients');
      final List<dynamic> data = json.decode(response.body);

      return data.map((json) => UserResponse.fromJson(json)).toList();
    } catch (e) {
      throw PlanException('Error al obtener lista de pacientes: $e');
    }
  }
}

class PlanException {
  PlanException(String s);
}