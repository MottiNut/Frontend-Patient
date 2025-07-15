import 'dart:async';
import 'dart:convert';
import 'package:frontendpatient/nutrition_plan/domain/models/enums.dart';
import 'package:frontendpatient/commons/constants/api_constants.dart';
import 'package:frontendpatient/commons/utils/api_error.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendpatient/nutrition_plan/data/dtos/daily_plan_dto.dart';
import 'package:frontendpatient/nutrition_plan/data/dtos/weekly_plan_dto.dart';
import 'package:frontendpatient/nutrition_plan/data/dtos/pending_patient_acceptance_dto.dart';
import 'package:frontendpatient/nutrition_plan/data/dtos/patient_plan_response_request_dto.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/daily_plan.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/weekly_plan.dart';
import 'package:frontendpatient/nutrition_plan/domain/models/pending_patient_acceptance.dart';

class NoPlanFoundException implements Exception {
  final String message;
  NoPlanFoundException(this.message);

  @override
  String toString() => message;
}

class NutritionPlanService {
  static const String baseUrl = ApiConstants.nutrition;
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
              .map((json) => PendingPatientAcceptanceDto.fromJson(json))
              .map((dto) => dto.toDomain())
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

  // Responder a un plan (aceptar o rechazar)
  Future<String> respondToPlan(
      int planId,
      PatientAction action,
      {String? feedback}
      ) async {
    try {
      final headers = await _getHeaders();
      final requestDto = PatientPlanResponseRequestDto(
        action: action.value,
        feedback: feedback,
      );

      print('Enviando solicitud a: $baseUrl/$planId/respond');
      print('Cuerpo: ${json.encode(requestDto.toJson())}');

      final response = await _client.post(
        Uri.parse('$baseUrl/$planId/respond'),
        headers: headers,
        body: json.encode(requestDto.toJson()),
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

  // Obtener plan del día de hoy
  Future<DailyPlan> getTodayPlan() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl/today'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final dto = DailyPlanDto.fromJson(decodedBody);
          return dto.toDomain();
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
  Future<DailyPlan> getDayPlan(int dayNumber, {String? date}) async {
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
          final dto = DailyPlanDto.fromJson(decodedBody);
          return dto.toDomain();
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
  Future<WeeklyPlan> getWeeklyPlan({String? date}) async {
    try {
      String url = '$baseUrl/weekly';
      if (date != null) {
        url += '?date=$date';
      }

      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedBody = _safeJsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final dto = WeeklyPlanDto.fromJson(decodedBody);
          return dto.toDomain();
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
  Future<List<WeeklyPlan>> getPlanHistory() async {
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
              .map((json) => WeeklyPlanDto.fromJson(json))
              .map((dto) => dto.toDomain())
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

  // Métodos de conveniencia para las acciones del paciente
  Future<String> acceptPlan(int planId, {String? feedback}) async {
    return respondToPlan(planId, PatientAction.accept, feedback: feedback);
  }

  Future<String> rejectPlan(int planId, {String? feedback}) async {
    return respondToPlan(planId, PatientAction.reject, feedback: feedback);
  }

  // Obtener plan por día de la semana (1=Lunes, 7=Domingo)
  Future<DailyPlan> getMondayPlan({String? date}) => getDayPlan(1, date: date);
  Future<DailyPlan> getTuesdayPlan({String? date}) => getDayPlan(2, date: date);
  Future<DailyPlan> getWednesdayPlan({String? date}) => getDayPlan(3, date: date);
  Future<DailyPlan> getThursdayPlan({String? date}) => getDayPlan(4, date: date);
  Future<DailyPlan> getFridayPlan({String? date}) => getDayPlan(5, date: date);
  Future<DailyPlan> getSaturdayPlan({String? date}) => getDayPlan(6, date: date);
  Future<DailyPlan> getSundayPlan({String? date}) => getDayPlan(7, date: date);

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