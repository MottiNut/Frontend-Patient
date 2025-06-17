import 'package:flutter/foundation.dart';
import 'package:frontendpatient/models/auth/login_request.dart';
import 'package:frontendpatient/models/auth/register_nutritionist_request.dart';
import 'package:frontendpatient/models/auth/register_patient_request.dart';
import 'package:frontendpatient/models/auth/update_profile.dart';
import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/models/user/user_model.dart';
import 'package:frontendpatient/service/auth_service.dart';

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
  User? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        _currentUser = user;
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error verificando autenticación: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      // Obtener el profile completo del usuario
      _currentUser = await _authService.getCurrentUser();
      _setState(AuthState.authenticated);

      return true;
    } catch (e) {
      _setError('Error en login: $e');
      return false;
    }
  }

  Future<bool> registerPatient({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? phone,
    double? height,
    double? weight,
    bool? hasMedicalCondition,
    String? chronicDisease,
    String? allergies,
    String? dietaryPreferences,
    String? gender,
  }) async {
    print('🔄 AuthProvider.registerPatient iniciado');
    print('📧 Email: $email');
    print('👤 Nombre completo: $firstName $lastName');

    _setState(AuthState.loading);
    print('⏳ Estado cambiado a loading');

    try {
      final request = RegisterPatientRequest(
        email: email,
        password: password,
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
        gender: gender,
      );

      print('📋 RegisterPatientRequest creado');
      print('🌐 Llamando al AuthService.registerPatient...');

      final response = await _authService.registerPatient(request);

      print('✅ Respuesta del servidor recibida');
      print('🔑 Token recibido: ${response.token.substring(0, 20)}...');

      print('👤 Obteniendo información del usuario actual...');
      _currentUser = await _authService.getCurrentUser();

      print('✅ Usuario actual obtenido: ${_currentUser?.firstName} ${_currentUser?.lastName}');

      _setState(AuthState.authenticated);
      print('🔐 Estado cambiado a authenticated');

      return true;
    } catch (e) {
      print('❌ ERROR en registerPatient: $e');
      print('📍 Tipo de error: ${e.runtimeType}');

      _setError('Error en registro: $e');
      print('💬 Error establecido: $errorMessage');

      return false;
    }
  }

  Future<bool> registerNutritionist({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? phone,
    required String licenseNumber,
    required String specialization,
    required String workplace,
  }) async {
    _setState(AuthState.loading);

    try {
      final request = RegisterNutritionistRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        phone: phone,
        licenseNumber: licenseNumber,
        specialization: specialization,
        workplace: workplace,
      );

      final response = await _authService.registerNutritionist(request);
      _currentUser = await _authService.getCurrentUser();
      _setState(AuthState.authenticated);

      return true;
    } catch (e) {
      _setError('Error en registro: $e');
      return false;
    }
  }

  Future<bool> updatePatientProfile(UpdatePatientProfileRequest request) async {
    if (_currentUser == null || _currentUser!.role != Role.patient) {
      _setError('Usuario no es paciente');
      return false;
    }

    _setState(AuthState.loading);

    try {
      final updatedPatient = await _authService.updatePatientProfile(request);
      _currentUser = updatedPatient;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Error actualizando profile: $e');
      return false;
    }
  }

  Future<bool> updateNutritionistProfile(UpdateNutritionistProfileRequest request) async {
    if (_currentUser == null || _currentUser!.role != Role.nutritionist) {
      _setError('Usuario no es nutricionista');
      return false;
    }

    _setState(AuthState.loading);

    try {
      final updatedNutritionist = await _authService.updateNutritionistProfile(request);
      _currentUser = updatedNutritionist;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Error actualizando profile: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _authService.logout();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Error en logout: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }
}