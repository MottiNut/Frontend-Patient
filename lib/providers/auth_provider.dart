// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:frontendpatient/models/user_model.dart';
import 'package:frontendpatient/service/auth_service.dart';
import 'package:frontendpatient/utils/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserResponse? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  String? _token; // Agregar variable para almacenar el token

  // Getters
  AuthStatus get status => _status;
  UserResponse? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isPatient => _currentUser?.role == 'patient';
  bool get isNutritionist => _currentUser?.role == 'nutritionist';
  String? get token => _token; // Getter para el token

  // Inicializar el estado de autenticación
  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        // Obtener el token almacenado
        _token = await _authService.getStoredToken(); // Necesitas este método en AuthService
        // Intentar obtener información del usuario actual
        await getCurrentUser();
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setStatus(AuthStatus.unauthenticated);
      _setError('Error al inicializar autenticación');
    } finally {
      _setLoading(false);
    }
  }

  // Registrar usuario
  Future<bool> register({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String phone,
    double? height,
    double? weight,
    int hasMedicalCondition = 0,
    String? chronicDisease,
    String? allergies,
    String? dietaryPreferences,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userCreate = UserCreate(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        phone: phone,
        height: height,
        weight: weight,
        hasMedicalCondition: hasMedicalCondition,
        chronicDisease: chronicDisease,
        allergies: allergies,
        dietaryPreferences: dietaryPreferences,
      );

      final authResponse = await _authService.register(userCreate);

      if (authResponse.token.isNotEmpty) {
        _token = authResponse.token; // Almacenar el token
        // Obtener información completa del usuario
        await getCurrentUser();
        return true;
      }

      _setError('Error en el registro');
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final userLogin = UserLogin(email: email, password: password);
      final authResponse = await _authService.login(userLogin);

      if (authResponse.token.isNotEmpty) {
        _token = authResponse.token; // Almacenar el token
        // Obtener información completa del usuario
        await getCurrentUser();
        return true;
      }

      _setError('Error en el inicio de sesión');
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener usuario actual
  Future<void> getCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      _handleError(e);
      await logout(); // Si no puede obtener el usuario, cerrar sesión
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _currentUser = null;
      _token = null; // Limpiar el token
      _setStatus(AuthStatus.unauthenticated);
      _clearError();
    } catch (e) {
      _setError('Error al cerrar sesión');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar información del usuario (para uso futuro)
  void updateUser(UserResponse user) {
    _currentUser = user;
    notifyListeners();
  }

  // Métodos privados para manejo de estado
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _handleError(dynamic error) {
    if (error is UnauthorizedException) {
      _setError('Credenciales incorrectas');
      logout(); // Cerrar sesión si el token es inválido
    } else if (error is ValidationException) {
      _setError(error.message);
    } else if (error is NetworkException) {
      _setError('Error de conexión. Verifica tu internet.');
    } else if (error is ApiException) {
      _setError(error.message);
    } else {
      _setError('Error inesperado: ${error.toString()}');
    }
  }



  // Limpiar mensajes de error
  void clearError() {
    _clearError();
  }
}