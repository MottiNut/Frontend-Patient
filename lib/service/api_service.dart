// lib/services/api_service.dart
// Servicio centralizado para manejar configuraciones comunes
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Cambia por tu URL

  // Método para obtener headers comunes
  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Método para manejar errores HTTP comunes
  static String handleHttpError(int statusCode, String responseBody) {
    try {
      final errorData = json.decode(responseBody);
      return errorData['detail'] ?? 'Error desconocido';
    } catch (e) {
      switch (statusCode) {
        case 401:
          return 'No autorizado. Token inválido o expirado.';
        case 403:
          return 'Acceso denegado. Permisos insuficientes.';
        case 404:
          return 'Recurso no encontrado.';
        case 422:
          return 'Datos de entrada inválidos.';
        case 500:
          return 'Error interno del servidor.';
        default:
          return 'Error: $statusCode';
      }
    }
  }
}