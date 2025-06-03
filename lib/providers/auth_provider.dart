// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:frontendpatient/service/auth_service.dart';
import '../models/patient_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Patient? _currentPatient;
  bool _isLoading = false;
  String? _error;

  // Getters
  Patient? get currentPatient => _currentPatient;
  bool get isLoggedIn => _currentPatient != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  AuthProvider() {
    _checkSession();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(email, password);

    if (result.success && result.patient != null) {
      _currentPatient = result.patient;
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _setError(result.error ?? 'Error desconocido');
      _setLoading(false);
      return false;
    }
  }

  // Registro
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthDate,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      birthDate: birthDate,
    );

    if (result.success && result.patient != null) {
      _currentPatient = result.patient;
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _setError(result.error ?? 'Error desconocido');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentPatient = null;
    _clearError();
    notifyListeners();
  }

  // Verificar sesión
  Future<void> _checkSession() async {
    _setLoading(true);

    final hasSession = await _authService.checkSession();
    if (hasSession) {
      _currentPatient = _authService.currentPatient;
    }

    _setLoading(false);
    notifyListeners();
  }

  // Métodos privados de utilidad
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Limpiar error manualmente
  void clearError() {
    _clearError();
  }
}