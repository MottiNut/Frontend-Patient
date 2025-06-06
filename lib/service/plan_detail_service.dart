
// lib/services/plan_detail_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan_detail.dart';

class PlanDetailService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Cambia por tu URL

  // Obtener detalles de un plan específico
  static Future<List<PlanDetail>> getPlanDetailsByPlan(
      String token, int planId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plan-details/plan/$planId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((detail) => PlanDetail.fromJson(detail)).toList();
      } else {
        throw Exception('Error al obtener detalles del plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo detalle de plan (solo nutricionistas)
  static Future<Map<String, dynamic>> createPlanDetail(
      String token, PlanDetailCreate detail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/plan-details'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(detail.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear detalle del plan');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar un detalle de plan
  static Future<Map<String, dynamic>> deletePlanDetail(
      String token, int detailId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/plan-details/$detailId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar detalle del plan');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar un detalle de plan
  static Future<Map<String, dynamic>> updatePlanDetail(
      String token, int detailId, PlanDetailCreate detail) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/plan-details/$detailId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(detail.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar detalle del plan');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}