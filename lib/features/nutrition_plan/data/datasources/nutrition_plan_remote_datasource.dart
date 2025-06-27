import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entities/daily_plan_entity.dart';
import '../entities/weekly_plan_entity.dart';
import '../entities/pending_acceptance_entity.dart';

abstract class NutritionPlanRemoteDataSource {
  Future<List<PendingAcceptanceEntity>> getPendingAcceptancePlans();
  Future<String> respondToPlan(int planId, Map<String, dynamic> request);
  Future<DailyPlanEntity> getTodayPlan();
  Future<DailyPlanEntity> getDayPlan(int dayNumber, {String? date});
  Future<WeeklyPlanEntity> getWeeklyPlan({String? date});
  Future<List<WeeklyPlanEntity>> getPlanHistory();
}

class NutritionPlanRemoteDataSourceImpl implements NutritionPlanRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  NutritionPlanRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  Future<Map<String, String>> _getHeaders() async {
    // Implementation similar to your original service
    // Get token from SharedPreferences
    throw UnimplementedError();
  }

  @override
  Future<List<PendingAcceptanceEntity>> getPendingAcceptancePlans() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/pending-acceptance'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PendingAcceptanceEntity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pending plans');
    }
  }

  @override
  Future<DailyPlanEntity> getTodayPlan() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/today'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return DailyPlanEntity.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('No tienes comidas programadas para hoy');
    } else {
      throw Exception('Failed to load today plan');
    }
  }

  @override
  Future<DailyPlanEntity> getDayPlan(int dayNumber, {String? date}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/day/$dayNumber').replace(
      queryParameters: date != null ? {'date': date} : null,
    );

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return DailyPlanEntity.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('No hay plan para este día');
    } else {
      throw Exception('Failed to load day plan');
    }
  }

  @override
  Future<WeeklyPlanEntity> getWeeklyPlan({String? date}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/weekly').replace(
      queryParameters: date != null ? {'date': date} : null,
    );

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return WeeklyPlanEntity.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('No hay plan semanal disponible');
    } else {
      throw Exception('Failed to load weekly plan');
    }
  }

  @override
  Future<List<WeeklyPlanEntity>> getPlanHistory() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => WeeklyPlanEntity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load plan history');
    }
  }

  @override
  Future<String> respondToPlan(int planId, Map<String, dynamic> request) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/respond/$planId'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['message'] ?? 'Respuesta enviada correctamente';
    } else {
      throw Exception('Failed to respond to plan');
    }
  }

}