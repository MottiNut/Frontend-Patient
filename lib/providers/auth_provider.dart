// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/models/user_model.dart';
import 'package:frontendpatient/service/auth_service.dart';
import '../models/enums.dart';
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserResponse? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  UserResponse? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isPatient => _currentUser?.role == UserRole.patient;
  bool get isNutritionist => _currentUser?.role == UserRole.nutritionist;

  /// Inicializar el estado de autenticación
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final hasToken = await _authService.isAuthenticated();

      if (hasToken) {
        // Verificar si el token sigue siendo válido
        final isValid = await _authService.validateToken();

        if (isValid) {
          // Obtener información del usuario
          await _loadUserProfile();
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error al inicializar autenticación: $e');
    }
  }

  /// Registrar nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    required UserRole role,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String phone,
    double? height,
    double? weight,
    bool hasMedicalCondition = false,
    String? chronicDisease,
    String? allergies,
    String? dietaryPreferences,
  }) async {
    _setLoading(true);

    try {
      final userCreate = UserCreate(
        email: email,
        password: password,
        role: role.name,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        phone: phone,
        height: height,
        weight: weight,
        hasMedicalCondition: hasMedicalCondition ? 1 : 0,
        chronicDisease: chronicDisease,
        allergies: allergies,
        dietaryPreferences: dietaryPreferences,
      );

      final authResponse = await _authService.register(userCreate);

      if (authResponse.token != null) {
        await _loadUserProfile();
        return true;
      } else {
        _setError('Error en el registro: No se recibió token');
        return false;
      }
    } catch (e) {
      _setError('Error al registrar: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Iniciar sesión
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final userLogin = UserLogin(email: email, password: password);
      final authResponse = await _authService.login(userLogin);

      if (authResponse.token != null) {
        await _loadUserProfile();
        return true;
      } else {
        _setError('Error en el login: No se recibió token');
        return false;
      }
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar perfil del usuario
  Future<bool> updateProfile() async {
    if (!isAuthenticated) return false;

    _setLoading(true);

    try {
      await _loadUserProfile();
      return true;
    } catch (e) {
      _setError('Error al actualizar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar conexión con la API
  Future<bool> checkConnection() async {
    try {
      return await _authService.checkApiHealth();
    } catch (e) {
      return false;
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(AuthState.unauthenticated);
    }
    notifyListeners();
  }

  /// Cargar perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _authService.getProfile();
      _currentUser = userProfile;
      _setState(AuthState.authenticated);
    } catch (e) {
      throw Exception('Error al cargar perfil: $e');
    }
  }

  /// Establecer estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establecer estado
  void _setState(AuthState newState) {
    _state = newState;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Establecer error
  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }
}

/// Extension para obtener nombre completo del usuario
extension UserResponseExtension on UserResponse {
  String get fullName => '$firstName $lastName';

  int get age {
    final birthDateTime = DateTime.parse(birthDate);
    final now = DateTime.now();
    int age = now.year - birthDateTime.year;

    if (now.month < birthDateTime.month ||
        (now.month == birthDateTime.month && now.day < birthDateTime.day)) {
      age--;
    }

    return age;
  }
}