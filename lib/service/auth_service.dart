// lib/services/auth_service.dart

import 'dart:convert';
import 'package:frontendpatient/models/user_model.dart';
import 'package:frontendpatient/utils/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Cambia esta URL por la de tu servidor FastAPI
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Headers comunes
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Obtener headers con token de autorización
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  // En tu AuthService
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Manejar respuestas HTTP
  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        }
        return null;
      case 400:
        final errorData = json.decode(response.body);
        throw ValidationException(errorData['detail'] ?? 'Error de validación');
      case 401:
        final errorData = json.decode(response.body);
        throw UnauthorizedException(errorData['detail'] ?? 'No autorizado');
      case 403:
        final errorData = json.decode(response.body);
        throw ForbiddenException(errorData['detail'] ?? 'Acceso prohibido');
      case 404:
        final errorData = json.decode(response.body);
        throw NotFoundException(errorData['detail'] ?? 'No encontrado');
      case 422:
        final errorData = json.decode(response.body);
        throw ValidationException(errorData['detail'] ?? 'Error de validación');
      case 500:
        throw ServerException('Error interno del servidor');
      default:
        throw ApiException(
          'Error inesperado: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  // Registrar usuario
  Future<AuthResponse> register(UserCreate userCreate) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: json.encode(userCreate.toJson()),
      );

      final data = _handleResponse(response);

      if (data != null) {
        final authResponse = AuthResponse.fromJson(data);

        // Guardar token en SharedPreferences
        if (authResponse.token.isNotEmpty) {
          await _saveToken(authResponse.token);
          if (authResponse.userId != null) {
            await _saveUserId(authResponse.userId!);
          }
          if (authResponse.role != null) {
            await _saveUserRole(authResponse.role!);
          }
        }

        return authResponse;
      }

      throw ApiException('Respuesta vacía del servidor');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  // Iniciar sesión
  Future<AuthResponse> login(UserLogin userLogin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: json.encode(userLogin.toJson()),
      );

      final data = _handleResponse(response);

      if (data != null) {
        final authResponse = AuthResponse.fromJson(data);

        // Guardar token en SharedPreferences
        if (authResponse.token.isNotEmpty) {
          await _saveToken(authResponse.token);
          if (authResponse.userId != null) {
            await _saveUserId(authResponse.userId!);
          }
          if (authResponse.role != null) {
            await _saveUserRole(authResponse.role!);
          }
        }

        return authResponse;
      }

      throw ApiException('Respuesta vacía del servidor');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener información del usuario actual
  Future<UserResponse> getCurrentUser() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
      );

      final data = _handleResponse(response);

      if (data != null) {
        return UserResponse.fromJson(data);
      }

      throw ApiException('Respuesta vacía del servidor');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Obtener ID de usuario guardado
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Obtener rol de usuario guardado
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Guardar token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Guardar ID de usuario
  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  // Guardar rol de usuario
  Future<void> _saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }
}