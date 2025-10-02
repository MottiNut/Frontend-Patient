import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/auth/data/dtos/login_request.dart';
import 'package:frontendpatient/auth/data/dtos/register_nutritionist_request.dart';
import 'package:frontendpatient/auth/data/dtos/register_patient_request.dart';
import 'package:frontendpatient/auth/data/dtos/update_profile.dart';
import 'package:frontendpatient/auth/domain/models/role.dart';
import 'package:frontendpatient/auth/domain/models/user.dart';
import 'package:frontendpatient/notification/presentation/providers/notification_provider.dart';
import 'package:frontendpatient/auth/application/services/auth_service.dart';
import 'package:frontendpatient/commons/widgets/app_navigation_handler.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  loggingOut,
}

enum VerificationMethod {
  email,
  sms,
  whatsapp;

  String get displayName {
    switch (this) {
      case VerificationMethod.email:
        return 'email';
      case VerificationMethod.sms:
        return 'sms';
      case VerificationMethod.whatsapp:
        return 'whatsApp';
    }
  }
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  NotificationProvider? _notificationProvider;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isUpdatingImage = false;
  bool _isAppInitialized = false;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  String? _userId;
  String? _email;
  Map<String, dynamic>? _user;

  bool _isVerificationPending = false;
  String? _verificationMethod;
  String? _pendingVerificationEmail;
  String? _pendingVerificationPhone;

  // Getters optimizados
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isUpdatingImage => _isUpdatingImage;
  bool get isLoggingOut => _state == AuthState.loggingOut;

  // NUEVO: Getters de verificación
  bool get isVerificationPending => _isVerificationPending;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  String? get pendingVerificationPhone => _pendingVerificationPhone;

  void setNotificationProvider(NotificationProvider notificationProvider) {
    _notificationProvider = notificationProvider;
    debugPrint('📱 NotificationProvider injected into AuthProvider');
  }

  Future<void> initializeApp() async {
    if (_isAppInitialized) {
      AppNavigationHandler.resetToHome();
      debugPrint('⚠️ App already initialized');
      return;
    }

    debugPrint('🚀 Initializing app...');
    _setState(AuthState.loading);

    try {
      _initializeNotificationsAsync();
      await _checkAuthStatusInternal();
      _isAppInitialized = true;
      debugPrint('✅ App initialization completed');
    } catch (e) {
      _setError('Error inicializando aplicación: $e');
      debugPrint('❌ Error in app initialization: $e');
    }
  }

  void _initializeNotificationsAsync() {
    _notificationProvider?.initialize().then((_) {
      debugPrint('✅ Notifications initialized');
    }).catchError((e) {
      debugPrint('⚠️ Notification initialization error (non-critical): $e');
    });
  }

  Future<void> _checkAuthStatusInternal() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _setState(AuthState.authenticated);
        _configureNotificationsForUser();
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error verificando autenticación: $e');
      debugPrint('❌ Error checking auth status: $e');
    }
  }

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

  // MODIFICADO: Registro de paciente con verificación
  // NOTA IMPORTANTE: En registerPatient, eliminar cualquier navegación automática
// El método solo debe retornar true/false y actualizar el estado
// La navegación debe ser manejada SOLO por la UI (RegisterScreen)

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

    // NO cambiar estado a loading aquí si ya lo maneja _executeAuthOperation
    clearError(); // Limpiar errores previos

    return _executeAuthOperation(() async {
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

      // Configurar verificación pendiente
      _isVerificationPending = true;
      _pendingVerificationEmail = email;
      _pendingVerificationPhone = phone;

      debugPrint('✅ Registro exitoso - Verificación pendiente');
      debugPrint('📧 Email pendiente: $email');

      return true;
    }, 'Error en registro');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> sendVerificationCode({
    required VerificationMethod method,
    String? phoneNumber,
  }) async {
    if (_pendingVerificationEmail == null && _email == null) {
      _setError('No hay usuario pendiente de verificación');
      return false;
    }

    _setLoading(true);
    clearError();

    try {

      final response = await _authService.sendVerificationCode(
        email: _pendingVerificationEmail ?? _email!,
        method: method,
        phoneNumber: phoneNumber,
      );

      if (response.success) {
        _verificationMethod = method.name;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Error enviando código');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> verifyCode(String code) async {
    if (_pendingVerificationEmail == null && _email == null) {
      _setError('No hay verificación pendiente');
      return {
        'success': false,
        'message': 'No hay verificación pendiente'
      };
    }

    _setLoading(true);
    clearError();

    try {
      final response = await _authService.verifyCode(
        email: _pendingVerificationEmail ?? _email!,
        code: code,
      );

      // CORRECCIÓN PRINCIPAL: Verificar también el mensaje para casos de éxito
      bool isActualSuccess = response.success;

      // Si el backend responde con success=false pero mensaje indica éxito
      if (!isActualSuccess && response.message != null) {
        String message = response.message!.toLowerCase();
        if (message.contains('verificado exitosamente') ||
            message.contains('email verificado') ||
            message.contains('verificado correctamente') ||
            message.contains('verification successful')) {
          isActualSuccess = true;
        }
      }

      if (isActualSuccess) {
        // Limpiar estado de verificación
        _isVerificationPending = false;
        _verificationMethod = null;
        _pendingVerificationEmail = null;

        return {
          'success': true,
          'message': response.message ?? 'Verificación exitosa',
          'verificationStatus': response.verificationStatus,
          'isAuthenticated': false,
          'requiresLogin': true
        };
      } else {
        _setError(response.message ?? 'Código inválido');
        return {
          'success': false,
          'message': response.message ?? 'Código inválido'
        };
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  /*Future<bool> resendVerificationCode() async {
    if (_pendingVerificationEmail == null && _email == null) {
      _setError('No hay verificación pendiente');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      final response = await _authService.resendVerificationCode(
        email: _pendingVerificationEmail ?? _email!,
      );

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Error reenviando código');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }*/

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

  Future<void> logout() async {
    debugPrint('👋 Starting logout process...');
    _setState(AuthState.loggingOut);

    try {
      await _clearNotifications();
      AppNavigationHandler.resetToHome();

      await _authService.logout().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ Auth services logout timeout');
          throw Exception('Logout timeout');
        },
      );

      debugPrint('✅ Auth services logout completed');
    } catch (e) {
      debugPrint('⚠️ Error in logout process: $e');
    } finally {
      _clearLocalState();
      _setState(AuthState.unauthenticated);
      debugPrint('✅ Logout completed');
    }
  }

  Future<bool> _executeAuthOperation(
      Future<bool> Function() operation,
      String errorPrefix,
      ) async {
    if (_errorMessage != null) {
      _errorMessage = null;
    }

    _setState(AuthState.loading);

    try {
      final result = await operation();

      if (result) {
        // Si hay verificación pendiente, mantener como unauthenticated
        if (_isVerificationPending) {
          _setState(AuthState.unauthenticated);
          debugPrint('✅ Operación exitosa - verificación pendiente');
        } else {
          _setState(AuthState.authenticated);
          debugPrint('✅ Operación exitosa - autenticado');
        }
      } else {
        // Operación falló pero sin error explícito
        _setState(AuthState.unauthenticated);
        debugPrint('⚠️ Operación retornó false');
      }

      return result;
    } catch (e) {
      _setError('$errorPrefix: $e');
      debugPrint('❌ $errorPrefix: $e');
      // NO navegar aquí, solo actualizar estado
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
    _isVerificationPending = false;
    _verificationMethod = null;
    _pendingVerificationEmail = null;
    _pendingVerificationPhone = null;
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

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (_state == AuthState.error) {
        _state = _currentUser != null
            ? AuthState.authenticated
            : AuthState.unauthenticated;
      }
      notifyListeners();
    }
  }

  void resetState() {
    _state = AuthState.initial;
    _currentUser = null;
    _errorMessage = null;
    _isUpdatingImage = false;
    _isAppInitialized = false;
    _isVerificationPending = false;
    _verificationMethod = null;
    _pendingVerificationEmail = null;
    _pendingVerificationPhone = null;
    notifyListeners();
  }
}