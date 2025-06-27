import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/features/auth/domain/models/update_profile.dart';
import 'package:frontendpatient/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontendpatient/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontendpatient/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:frontendpatient/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontendpatient/features/auth/data/value_objects/role.dart';
import 'package:frontendpatient/features/auth/domain/usecases/update_patient_profile_usecase.dart';
import 'package:frontendpatient/features/auth/data/entities/user.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterPatientUseCase _registerPatientUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final UpdatePatientProfileUseCase _updatePatientProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterPatientUseCase registerPatientUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required UpdatePatientProfileUseCase updatePatientProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  }) : _loginUseCase = loginUseCase,
        _registerPatientUseCase = registerPatientUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _updatePatientProfileUseCase = updatePatientProfileUseCase,
        _logoutUseCase = logoutUseCase,
        _authRepository = authRepository;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isUpdatingImage = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isUpdatingImage => _isUpdatingImage;

  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _getCurrentUserUseCase();
        _currentUser = user;
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error verificando autenticación: $e');
    }
  }

  void updateCurrentUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    try {
      await _loginUseCase(email, password);
      _currentUser = await _getCurrentUserUseCase();
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
    _setState(AuthState.loading);
    try {
      await _registerPatientUseCase(
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
      _currentUser = await _getCurrentUserUseCase();
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
      final updatedPatient = await _updatePatientProfileUseCase(request);
      _currentUser = updatedPatient;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Error actualizando profile: $e');
      return false;
    }
  }

  Future<bool> updatePatientProfileImage(File? imageFile) async {
    if (_currentUser == null || _currentUser!.role != Role.patient) {
      _setError('Usuario no es paciente');
      return false;
    }
    _setImageUpdating(true);
    try {
      final updatedPatient = await _authRepository.updatePatientProfileImage(imageFile);
      _currentUser = updatedPatient;
      _setImageUpdating(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setImageUpdating(false);
      _setError('Error actualizando imagen de perfil: $e');
      return false;
    }
  }

  Future<Uint8List?> getPatientProfileImage(int userId) async {
    try {
      return await _authRepository.getPatientProfileImage(userId);
    } catch (e) {
      print('Error obteniendo imagen de perfil: $e');
      return null;
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);
    try {
      await _logoutUseCase();
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

  void _setImageUpdating(bool updating) {
    _isUpdatingImage = updating;
    notifyListeners();
  }
}