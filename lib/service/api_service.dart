// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Cambiar por tu URL
  static const String _tokenKey = 'auth_token';

  // Headers base para todas las peticiones
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con autenticación
  Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    final headers = Map<String, String>.from(_baseHeaders);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Guardar token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Obtener token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Eliminar token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Verificar si hay token
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // GET request
  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = requireAuth ? await _authHeaders : _baseHeaders;

    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // POST request
  Future<http.Response> post(String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = requireAuth ? await _authHeaders : _baseHeaders;

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // PUT request
  Future<http.Response> put(String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = requireAuth ? await _authHeaders : _baseHeaders;

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = requireAuth ? await _authHeaders : _baseHeaders;

    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // Manejar respuestas HTTP
  http.Response _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 400:
        throw ApiException(_getErrorMessage(response, 'Solicitud inválida'));
      case 401:
        throw UnauthorizedException(_getErrorMessage(response, 'No autorizado'));
      case 403:
        throw ForbiddenException(_getErrorMessage(response, 'Acceso denegado'));
      case 404:
        throw NotFoundException(_getErrorMessage(response, 'Recurso no encontrado'));
      case 422:
        throw ValidationException(_getErrorMessage(response, 'Error de validación'));
      case 500:
        throw ServerException(_getErrorMessage(response, 'Error interno del servidor'));
      default:
        throw ApiException(
            'Error HTTP ${response.statusCode}: ${_getErrorMessage(response, 'Error desconocido')}'
        );
    }
  }

  // Extraer mensaje de error de la respuesta
  String _getErrorMessage(http.Response response, String defaultMessage) {
    try {
      final data = json.decode(response.body);
      return data['detail'] ?? data['message'] ?? defaultMessage;
    } catch (e) {
      return defaultMessage;
    }
  }
}

// Excepciones personalizadas
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}