// auth_provider.dart - VERSIÓN CON LOGOUT CORREGIDO
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/models/auth/login_request.dart';
import 'package:frontendpatient/models/auth/register_nutritionist_request.dart';
import 'package:frontendpatient/models/auth/register_patient_request.dart';
import 'package:frontendpatient/models/auth/update_profile.dart';
import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/models/user/user_model.dart';
import 'package:frontendpatient/providers/notification_provider.dart';
import 'package:frontendpatient/service/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  loggingOut,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  NotificationProvider? _notificationProvider;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isUpdatingImage = false;
  bool _isAppInitialized = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isUpdatingImage => _isUpdatingImage;
  bool get isLoggingOut => _state == AuthState.loggingOut;

  void setNotificationProvider(NotificationProvider notificationProvider) {
    _notificationProvider = notificationProvider;
    debugPrint('📱 NotificationProvider injected into AuthProvider');
  }

  Future<void> initializeApp() async {
    if (_isAppInitialized) {
      debugPrint('⚠️ App already initialized');
      return;
    }

    debugPrint('🚀 Initializing app...');
    _setState(AuthState.loading);

    try {
      // ✅ PASO 1: Inicializar notificaciones primero
      if (_notificationProvider != null) {
        await _notificationProvider!.initialize();
        debugPrint('✅ Notifications initialized');
      }

      await Future.delayed(const Duration(milliseconds: 100));

      // ✅ PASO 2: Verificar autenticación
      await _checkAuthStatusInternal();

      _isAppInitialized = true;
      debugPrint('✅ App initialization completed');

    } catch (e) {
      _setError('Error inicializando aplicación: $e');
      debugPrint('❌ Error in app initialization: $e');
    }
  }

  Future<void> _checkAuthStatusInternal() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        _currentUser = user;
        _setState(AuthState.authenticated);

        if (_notificationProvider != null) {
          await _notificationProvider!.onUserLoggedIn(_currentUser!.userId.toString());
          debugPrint('✅ Notifications configured for existing user: ${_currentUser!.userId}');
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error verificando autenticación: $e');
      debugPrint('❌ Error checking auth status: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    if (!_isAppInitialized) {
      await initializeApp();
    } else {
      await _checkAuthStatusInternal();
    }
  }

  void updateCurrentUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    debugPrint('🔐 Attempting login for: $email');
    _setState(AuthState.loading);

    try {
      final request = LoginRequest(email: email, password: password);
      await _authService.login(request);

      _currentUser = await _authService.getCurrentUser();
      _setState(AuthState.authenticated);

      if (_notificationProvider != null) {
        await _notificationProvider!.onUserLoggedIn(_currentUser!.userId.toString());
        debugPrint('✅ Notifications configured for logged in user: ${_currentUser!.userId}');
      }

      debugPrint('✅ Login successful for user: ${_currentUser!.userId}');
      return true;
    } catch (e) {
      _setError('Error en login: $e');
      debugPrint('❌ Login error: $e');
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
    debugPrint('🔄 AuthProvider.registerPatient iniciado');
    _setState(AuthState.loading);

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

      await _authService.registerPatient(request);
      _currentUser = await _authService.getCurrentUser();
      _setState(AuthState.authenticated);

      if (_notificationProvider != null) {
        await _notificationProvider!.onUserLoggedIn(_currentUser!.userId.toString());
        debugPrint('✅ Notifications configured for registered user: ${_currentUser!.userId}');
      }

      return true;
    } catch (e) {
      _setError('Error en registro: $e');
      debugPrint('❌ Error in registerPatient: $e');
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
    debugPrint('🔄 AuthProvider.registerNutritionist iniciado');
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

      await _authService.registerNutritionist(request);
      _currentUser = await _authService.getCurrentUser();
      _setState(AuthState.authenticated);

      if (_notificationProvider != null) {
        await _notificationProvider!.onUserLoggedIn(_currentUser!.userId.toString());
        debugPrint('✅ Notifications configured for registered nutritionist: ${_currentUser!.userId}');
      }

      return true;
    } catch (e) {
      _setError('Error en registro: $e');
      debugPrint('❌ Error registering nutritionist: $e');
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

  Future<bool> updatePatientProfileImage(File? imageFile) async {
    if (_currentUser == null || _currentUser!.role != Role.patient) {
      _setError('Usuario no es paciente');
      return false;
    }

    _setImageUpdating(true);

    try {
      final updatedPatient = await _authService.updatePatientProfileImage(imageFile);
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
      return await _authService.getPatientProfileImage(userId);
    } catch (e) {
      debugPrint('Error obteniendo imagen de perfil: $e');
      return null;
    }
  }

  // ✅ LOGOUT COMPLETAMENTE REDISEÑADO
  Future<void> logout() async {
    debugPrint('👋 Starting logout process...');

    // ✅ PASO 1: Cambiar estado inmediatamente
    _setState(AuthState.loggingOut);

    try {
      // ✅ PASO 2: Limpiar notificaciones de forma segura
      if (_notificationProvider != null) {
        try {
          debugPrint('🧽 Clearing notifications...');
          await _notificationProvider!.onUserLoggedOut().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⏰ Notification cleanup timeout - proceeding anyway');
            },
          );
          debugPrint('✅ Notifications cleared successfully');
        } catch (e) {
          debugPrint('⚠️ Error clearing notifications (non-critical): $e');
          // No rethrow - continuar con logout
        }
      }

      // ✅ PASO 3: Logout del servicio de forma segura
      try {
        debugPrint('🔓 Logging out from auth service...');
        await _authService.logout().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏰ Auth service logout timeout');
            throw Exception('Logout timeout');
          },
        );
        debugPrint('✅ Auth service logout completed');
      } catch (e) {
        debugPrint('⚠️ Error in auth service logout: $e');
        // Continuar - limpiar estado local de todos modos
      }

      // ✅ PASO 4: Limpiar estado local SIEMPRE
      _currentUser = null;
      _errorMessage = null;
      _isUpdatingImage = false;

      // ✅ PASO 5: Pequeña pausa para sincronización
      await Future.delayed(const Duration(milliseconds: 300));

      // ✅ PASO 6: Estado final GARANTIZADO
      _setState(AuthState.unauthenticated);

      debugPrint('✅ Logout completed successfully');

    } catch (e) {
      debugPrint('❌ Critical logout error: $e');

      // ✅ CRÍTICO: FORZAR logout local incluso con errores
      _currentUser = null;
      _errorMessage = null;
      _isUpdatingImage = false;

      // ✅ FORZAR estado unauthenticated - NO error
      _state = AuthState.unauthenticated;
      notifyListeners();

      debugPrint('🔧 Forced local logout completed');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AuthState newState) {
    debugPrint('🔄 AuthState changing from $_state to $newState');
    _state = newState;

    // ✅ Solo limpiar error si NO es logout o error
    if (newState != AuthState.loggingOut && newState != AuthState.error) {
      _errorMessage = null;
    }

    notifyListeners();
    debugPrint('✅ AuthState changed to: $_state');
  }

  void _setError(String error) {
    debugPrint('❌ Setting error state: $error');
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void _setImageUpdating(bool updating) {
    _isUpdatingImage = updating;
    notifyListeners();
  }
}