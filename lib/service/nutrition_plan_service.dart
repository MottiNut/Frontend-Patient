import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrition_plan/daily_plan_response.dart';
import '../models/nutrition_plan/nutririon_plan_model.dart';
import '../utils/ApiError.dart';

class NutritionPlanService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/bff/patient/nutrition-plans';
  static const String tokenKey = 'auth_token';
  final http.Client _client = http.Client();

  // Obtener token desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Headers con autorización
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token no encontrado');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener planes pendientes de aceptación por el paciente
  Future<List<PendingPatientAcceptance>> getPendingAcceptancePlans() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/pending-acceptance'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => PendingPatientAcceptance.fromJson(json))
            .toList();
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error obteniendo planes pendientes: $e');
    }
  }

  // Responder a un plan (aceptar o rechazar)
  Future<NutritionPlanResponse> respondToPlan(
      int planId,
      PatientPlanResponseRequest request,
      ) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl/$planId/respond'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return NutritionPlanResponse.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error respondiendo al plan: $e');
    }
  }

  // Obtener plan del día de hoy
  Future<DailyPlanResponse> getTodayPlan() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/today'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return DailyPlanResponse.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error obteniendo plan de hoy: $e');
    }
  }

  // Obtener plan de un día específico
  Future<DailyPlanResponse> getDayPlan(int dayNumber, {String? date}) async {
    try {
      final headers = await _getHeaders();

      String url = '$baseUrl/day/$dayNumber';
      if (date != null) {
        url += '?date=$date';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return DailyPlanResponse.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error obteniendo plan del día: $e');
    }
  }

  // Obtener plan semanal
  Future<WeeklyPlanResponse> getWeeklyPlan({String? date}) async {
    try {
      final headers = await _getHeaders();

      String url = '$baseUrl/weekly';
      if (date != null) {
        url += '?date=$date';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return WeeklyPlanResponse.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error obteniendo plan semanal: $e');
    }
  }

  // Obtener historial de planes
  Future<List<WeeklyPlanResponse>> getPlanHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => WeeklyPlanResponse.fromJson(json))
            .toList();
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error obteniendo historial de planes: $e');
    }
  }

  // Métodos de conveniencia para las acciones del paciente
  Future<NutritionPlanResponse> acceptPlan(int planId, {String? feedback}) async {
    final request = PatientPlanResponseRequest(
      action: PatientAction.accept.value,
      feedback: feedback,
    );
    return respondToPlan(planId, request);
  }

  Future<NutritionPlanResponse> rejectPlan(int planId, {String? feedback}) async {
    final request = PatientPlanResponseRequest(
      action: PatientAction.reject.value,
      feedback: feedback,
    );
    return respondToPlan(planId, request);
  }

  // Obtener plan por día de la semana (1=Lunes, 7=Domingo)
  Future<DailyPlanResponse> getMondayPlan({String? date}) => getDayPlan(1, date: date);
  Future<DailyPlanResponse> getTuesdayPlan({String? date}) => getDayPlan(2, date: date);
  Future<DailyPlanResponse> getWednesdayPlan({String? date}) => getDayPlan(3, date: date);
  Future<DailyPlanResponse> getThursdayPlan({String? date}) => getDayPlan(4, date: date);
  Future<DailyPlanResponse> getFridayPlan({String? date}) => getDayPlan(5, date: date);
  Future<DailyPlanResponse> getSaturdayPlan({String? date}) => getDayPlan(6, date: date);
  Future<DailyPlanResponse> getSundayPlan({String? date}) => getDayPlan(7, date: date);

  // Verificar si el token es válido
  Future<bool> isTokenValid() async {
    final token = await _getToken();
    return token != null;
  }

  // Limpiar cliente HTTP al finalizar
  void dispose() {
    _client.close();
  }
}