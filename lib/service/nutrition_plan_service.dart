// lib/services/nutrition_plan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_plan.dart';

class NutritionPlanService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Cambia por tu URL

  // Obtener mis planes nutricionales
  static Future<List<NutritionPlan>> getMyNutritionPlans(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition-plans/my-plans'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((plan) => NutritionPlan.fromJson(plan)).toList();
      } else {
        throw Exception('Error al obtener planes nutricionales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un plan nutricional específico
  static Future<NutritionPlan> getNutritionPlanById(
      String token, int planId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition-plans/$planId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return NutritionPlan.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener plan nutricional');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo plan nutricional (solo nutricionistas)
  static Future<Map<String, dynamic>> createNutritionPlan(
      String token, NutritionPlanCreate plan) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition-plans'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(plan.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear plan nutricional');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar estado de un plan nutricional
  static Future<Map<String, dynamic>> updatePlanStatus(
      String token, int planId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/nutrition-plans/$planId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar estado del plan');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}