// services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _databaseService = DatabaseService();
  Patient? _currentPatient;

  Patient? get currentPatient => _currentPatient;
  bool get isLoggedIn => _currentPatient != null;

  // Login
  Future<AuthResult> login(String email, String password) async {
    try {
      // Validar entrada
      if (email.trim().isEmpty || password.trim().isEmpty) {
        return AuthResult.error('Email y contraseña son requeridos');
      }

      // Buscar usuario en base de datos
      final userMap = await _databaseService.getUserByEmail(email.trim());

      if (userMap == null) {
        return AuthResult.error('Usuario no encontrado');
      }

      // Verificar contraseña (en producción usar hash)
      if (userMap['password'] != password) {
        return AuthResult.error('Contraseña incorrecta');
      }

      // Verificar que sea paciente
      final userRole = userMap['role'];
      if (userRole != 'patient') {
        return AuthResult.error('Solo los pacientes pueden acceder a esta aplicación');
      }

      // Crear objeto Patient
      _currentPatient = Patient.fromMap(userMap);

      // Guardar sesión
      await _saveSession(_currentPatient!.id!);

      return AuthResult.success(_currentPatient!);
    } catch (e) {
      return AuthResult.error('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // Registro
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    DateTime? birthDate,
  }) async {
    try {
      // Validaciones
      if (email.trim().isEmpty || password.trim().isEmpty ||
          firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult.error('Todos los campos son requeridos');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.error('Email no válido');
      }

      if (password.length < 6) {
        return AuthResult.error('La contraseña debe tener al menos 6 caracteres');
      }

      // Verificar si el email ya existe
      if (await _databaseService.emailExists(email.trim())) {
        return AuthResult.error('El email ya está registrado');
      }

      // Crear paciente
      final patient = Patient.create(
        email: email.trim(),
        password: password,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone?.trim(),
        birthDate: birthDate,
      );

      // Guardar en base de datos
      final patientMap = patient.toMap();
      final userId = await _databaseService.insertUser(patientMap);

      // Crear paciente con ID
      _currentPatient = patient.copyWithAll(id: userId);

      // Guardar sesión
      await _saveSession(userId);

      return AuthResult.success(_currentPatient!);
    } catch (e) {
      return AuthResult.error('Error al registrar usuario: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    _currentPatient = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('is_logged_in');
  }

  // Verificar sesión guardada
  Future<bool> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final userId = prefs.getInt('user_id');

      if (!isLoggedIn || userId == null) {
        return false;
      }

      // Buscar usuario en base de datos
      final userMap = await _databaseService.getUserByEmail('');
      // Como no tenemos el email, buscamos por ID (necesitarías modificar DatabaseService)
      // Por simplicidad, retornamos false aquí
      return false;
    } catch (e) {
      return false;
    }
  }

  // Guardar sesión
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setBool('is_logged_in', true);
  }

  // Validar email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Clase para resultados de autenticación
class AuthResult {
  final bool success;
  final String? error;
  final Patient? patient;

  AuthResult._({required this.success, this.error, this.patient});

  factory AuthResult.success(Patient patient) {
    return AuthResult._(success: true, patient: patient);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }
}