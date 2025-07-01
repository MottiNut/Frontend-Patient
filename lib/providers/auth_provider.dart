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
import 'package:frontendpatient/shared/widgets/app_navigation_handler.dart';

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

  // Getters optimizados
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isUpdatingImage => _isUpdatingImage;
  bool get isLoggingOut => _state == AuthState.loggingOut;

  // Método mejorado para inyección de dependencias
  void setNotificationProvider(NotificationProvider notificationProvider) {
    _notificationProvider = notificationProvider;
    debugPrint('📱 NotificationProvider injected into AuthProvider');
  }

  // Inicialización mejorada con mejor manejo de errores
  Future<void> initializeApp() async {
    if (_isAppInitialized) {
      AppNavigationHandler.resetToHome();
      debugPrint('⚠️ App already initialized');
      return;
    }

    debugPrint('🚀 Initializing app...');
    _setState(AuthState.loading);

    try {
      // Inicializar notificaciones de forma asíncrona
      _initializeNotificationsAsync();

      // Verificar estado de autenticación
      await _checkAuthStatusInternal();

      _isAppInitialized = true;
      debugPrint('✅ App initialization completed');
    } catch (e) {
      _setError('Error inicializando aplicación: $e');
      debugPrint('❌ Error in app initialization: $e');
    }
  }

  // Inicialización asíncrona de notificaciones para evitar bloqueo
  void _initializeNotificationsAsync() {
    _notificationProvider?.initialize().then((_) {
      debugPrint('✅ Notifications initialized');
    }).catchError((e) {
      debugPrint('⚠️ Notification initialization error (non-critical): $e');
    });
  }

  // Verificación de estado de auth optimizada
  Future<void> _checkAuthStatusInternal() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _setState(AuthState.authenticated);

        // Configurar notificaciones de forma asíncrona
        _configureNotificationsForUser();
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error verificando autenticación: $e');
      debugPrint('❌ Error checking auth status: $e');
    }
  }

  // Configuración asíncrona de notificaciones
  void _configureNotificationsForUser() {
    if (_notificationProvider != null && _currentUser != null) {
      _notificationProvider!
          .onUserLoggedIn(_currentUser!.userId.toString())
          .then((_) {
        debugPrint('✅ Notifications configured for user: ${_currentUser!.userId}');
      }).catchError((e) {
        debugPrint('⚠️ Error configuring notifications: $e');
      });
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

  // Login optimizado
  Future<bool> login(String email, String password) async {
    return _executeAuthOperation(() async {
      debugPrint('🔐 Attempting login for: $email');

      final request = LoginRequest(email: email, password: password);
      await _authService.login(request);
      _currentUser = await _authService.getCurrentUser();
      AppNavigationHandler.resetToHome();
      _configureNotificationsForUser();
      debugPrint('✅ Login successful for user: ${_currentUser!.userId}');

      return true;
    }, 'Error en login');
  }

  // Registro de paciente optimizado
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
    return _executeAuthOperation(() async {
      debugPrint('🔄 AuthProvider.registerPatient iniciado');

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

      _configureNotificationsForUser();
      return true;
    }, 'Error en registro');
  }

  // Registro de nutricionista optimizado
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
    return _executeAuthOperation(() async {
      debugPrint('🔄 AuthProvider.registerNutritionist iniciado');

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

      _configureNotificationsForUser();
      return true;
    }, 'Error en registro');
  }

  // Actualización de perfil optimizada
  Future<bool> updatePatientProfile(UpdatePatientProfileRequest request) async {
    if (!_validatePatientUser()) return false;

    return _executeAuthOperation(() async {
      _currentUser = await _authService.updatePatientProfile(request);
      return true;
    }, 'Error actualizando perfil');
  }

  Future<bool> updateNutritionistProfile(UpdateNutritionistProfileRequest request) async {
    if (!_validateNutritionistUser()) return false;

    return _executeAuthOperation(() async {
      _currentUser = await _authService.updateNutritionistProfile(request);
      return true;
    }, 'Error actualizando perfil');
  }

  // Actualización de imagen optimizada
  Future<bool> updatePatientProfileImage(File? imageFile) async {
    if (!_validatePatientUser()) return false;

    _setImageUpdating(true);
    try {
      _currentUser = await _authService.updatePatientProfileImage(imageFile);
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

  // Logout mejorado con mejor manejo de timeouts
  Future<void> logout() async {
    debugPrint('👋 Starting logout process...');
    _setState(AuthState.loggingOut);

    try {
      // Limpiar notificaciones con timeout
      await _clearNotifications();
      AppNavigationHandler.resetToHome();

      // Logout del servicio de auth con timeout
      await _authService.logout().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ Auth service logout timeout');
          throw Exception('Logout timeout');
        },
      );

      debugPrint('✅ Auth service logout completed');
    } catch (e) {
      debugPrint('⚠️ Error in logout process: $e');
    } finally {
      // Siempre limpiar el estado local
      _clearLocalState();
      _setState(AuthState.unauthenticated);
      debugPrint('✅ Logout completed');
    }
  }

  // Métodos auxiliares privados
  Future<bool> _executeAuthOperation(
      Future<bool> Function() operation,
      String errorPrefix,
      ) async {
    // Limpiar errores previos al iniciar nueva operación
    if (_errorMessage != null) {
      _errorMessage = null;
    }

    _setState(AuthState.loading);
    try {
      final result = await operation();
      if (result) {
        _setState(AuthState.authenticated);
      }
      return result;
    } catch (e) {
      _setError('$errorPrefix: $e');
      debugPrint('❌ $errorPrefix: $e');
      return false;
    }
  }

  bool _validatePatientUser() {
    if (_currentUser == null || _currentUser!.role != Role.patient) {
      _setError('Usuario no es paciente');
      return false;
    }
    return true;
  }

  bool _validateNutritionistUser() {
    if (_currentUser == null || _currentUser!.role != Role.nutritionist) {
      _setError('Usuario no es nutricionista');
      return false;
    }
    return true;
  }

  Future<void> _clearNotifications() async {
    if (_notificationProvider != null) {
      try {
        await _notificationProvider!.onUserLoggedOut().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⏰ Notification cleanup timeout - proceeding anyway');
          },
        );
        debugPrint('✅ Notifications cleared successfully');
      } catch (e) {
        debugPrint('⚠️ Error clearing notifications (non-critical): $e');
      }
    }
  }

  void _clearLocalState() {
    _currentUser = null;
    _errorMessage = null;
    _isUpdatingImage = false;
  }

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AuthState.error);
  }

  void _setImageUpdating(bool isUpdating) {
    if (_isUpdatingImage != isUpdating) {
      _isUpdatingImage = isUpdating;
      notifyListeners();
    }
  }

  // Método público para limpiar errores
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      // Si estamos en estado de error, volver al estado anterior apropiado
      if (_state == AuthState.error) {
        _state = _currentUser != null
            ? AuthState.authenticated
            : AuthState.unauthenticated;
      }
      notifyListeners();
    }
  }

  // Método para resetear el estado completo (útil para testing o casos especiales)
  void resetState() {
    _state = AuthState.initial;
    _currentUser = null;
    _errorMessage = null;
    _isUpdatingImage = false;
    _isAppInitialized = false;
    notifyListeners();
  }
}