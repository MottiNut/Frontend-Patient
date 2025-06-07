// lib/services/auth_service.dart
import 'dart:convert';
import 'package:frontendpatient/models/user_model.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Registrar nuevo usuario
  Future<AuthResponse> register(UserCreate userCreate) async {
    try {
      final response = await _apiService.post(
        '/register',
        body: userCreate.toJson(),
        requireAuth: false,
      );

      final data = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Guardar token automáticamente
      if (authResponse.token != null) {
        await _apiService.saveToken(authResponse.token);
      }

      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Iniciar sesión
  Future<AuthResponse> login(UserLogin userLogin) async {
    try {
      final response = await _apiService.post(
        '/login',
        body: userLogin.toJson(),
        requireAuth: false,
      );

      final data = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Guardar token automáticamente
      if (authResponse.token != null) {
        await _apiService.saveToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      // Eliminar token del almacenamiento local
      await _apiService.removeToken();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    return await _apiService.hasToken();
  }

  /// Obtener perfil del usuario actual
  Future<UserResponse> getProfile() async {
    try {
      final response = await _apiService.get('/profile');
      final data = json.decode(response.body);
      return UserResponse.fromJson(data);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Verificar estado de la API
  Future<bool> checkApiHealth() async {
    try {
      final response = await _apiService.get('/health', requireAuth: false);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar token
  Future<void> updateToken(String newToken) async {
    await _apiService.saveToken(newToken);
  }

  /// Obtener token actual
  Future<String?> getCurrentToken() async {
    return await _apiService.getToken();
  }

  /// Validar token (verificar si sigue siendo válido)
  Future<bool> validateToken() async {
    try {
      final response = await _apiService.get('/profile');
      return response.statusCode == 200;
    } catch (e) {
      if (e is UnauthorizedException) {
        // Token inválido, limpiarlo
        await logout();
        return false;
      }
      return false;
    }
  }

  /// Manejar errores de autenticación
  AuthException _handleAuthError(dynamic error) {
    if (error is ApiException) {
      return AuthException(error.message);
    } else if (error is UnauthorizedException) {
      return AuthException('Credenciales inválidas');
    } else if (error is ValidationException) {
      return AuthException('Datos de entrada inválidos');
    } else {
      return AuthException('Error de autenticación: $error');
    }
  }
}

/// Excepción específica para errores de autenticación
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}