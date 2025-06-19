import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrition_plan/daily_plan_response.dart';
import '../models/nutrition_plan/nutririon_plan_model.dart';
import '../shared/utils/ApiError.dart';
class NoPlanFoundException implements Exception {
  final String message;
  NoPlanFoundException(this.message);

  @override
  String toString() => message;
}

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

  // Método auxiliar para manejar respuestas JSON de forma segura
  dynamic _safeJsonDecode(String responseBody) {
    try {
      return json.decode(responseBody);
    } catch (e) {
      // Si no se puede decodificar como JSON, devolver el string original
      return responseBody;
    }
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
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is List) {
          return decodedBody
              .map((json) => PendingPatientAcceptance.fromJson(json))
              .toList();
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      } else {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final error = ApiError.fromJson(decodedBody);
          throw Exception(error.message);
        } else {
          throw Exception('Error ${response.statusCode}: ${response.reasonPhrase ?? 'Error desconocido'}');
        }
      }
    } catch (e) {
      throw Exception('Error obteniendo planes pendientes: $e');
    }
  }

  // Responder a un plan (aceptar o rechazar) - MÉTODO CORREGIDO
  Future<String> respondToPlan(
      int planId,
      PatientPlanResponseRequest request,
      ) async {
    try {
      final headers = await _getHeaders();

      print('Enviando solicitud a: $baseUrl/$planId/respond');
      print('Cuerpo: ${json.encode(request.toJson())}');

      final response = await _client.post(
        Uri.parse('$baseUrl/$planId/respond'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // En lugar de intentar parsear como JSON, devolver el mensaje directamente
        final decodedBody = _safeJsonDecode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          // Si es un objeto JSON, extraer el mensaje
          return decodedBody['message'] ?? 'Operación completada exitosamente';
        } else if (decodedBody is String) {
          // Si es un string, devolverlo directamente
          return decodedBody;
        } else {
          return 'Operación completada exitosamente';
        }
      } else {
        // Manejar errores
        final decodedBody = _safeJsonDecode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          final error = ApiError.fromJson(decodedBody);
          throw Exception(error.message);
        } else if (decodedBody is String) {
          throw Exception(decodedBody);
        } else {
          throw Exception('Error ${response.statusCode}: ${response.reasonPhrase ?? 'Error desconocido'}');
        }
      }
    } catch (e) {
      throw Exception('Error respondiendo al plan: $e');
    }
  }

  // Obtener plan del día de hoy - Modificado para manejar 404
  Future<DailyPlanResponse> getTodayPlan() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/today'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          return DailyPlanResponse.fromJson(decodedBody);
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      } else if (response.statusCode == 404) {
        throw NoPlanFoundException('No tienes comidas programadas para hoy');
      } else {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final error = ApiError.fromJson(decodedBody);
          throw Exception(error.message);
        } else {
          throw Exception('Error ${response.statusCode}: ${response.reasonPhrase ?? 'Error desconocido'}');
        }
      }
    } catch (e) {
      if (e is NoPlanFoundException) {
        rethrow;
      }
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
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          return DailyPlanResponse.fromJson(decodedBody);
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      } else {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final error = ApiError.fromJson(decodedBody);
          throw Exception(error.message);
        } else {
          throw Exception('Error ${response.statusCode}: ${response.reasonPhrase ?? 'Error desconocido'}');
        }
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
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          return WeeklyPlanResponse.fromJson(decodedBody);
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      } else {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final error = ApiError.fromJson(decodedBody);
          throw Exception(error.message);
        } else {
          throw Exception('Error ${response.statusCode}: ${response.reasonPhrase ?? 'Error desconocido'}');
        }
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
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is List) {
          return decodedBody
              .map((json) => WeeklyPlanResponse.fromJson(json))
              .toList();
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }
      } else {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final error = ApiError.fromJson(decodedBody);
          throw Exception(error.message);
        } else {
          throw Exception('Error ${response.statusCode}: ${response.reasonPhrase ?? 'Error desconocido'}');
        }
      }
    } catch (e) {
      throw Exception('Error obteniendo historial de planes: $e');
    }
  }

  // Métodos de conveniencia para las acciones del paciente - ACTUALIZADOS
  Future<String> acceptPlan(int planId, {String? feedback}) async {
    final request = PatientPlanResponseRequest(
      action: PatientAction.accept.value,
      feedback: feedback,
    );
    return respondToPlan(planId, request);
  }

  Future<String> rejectPlan(int planId, {String? feedback}) async {
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