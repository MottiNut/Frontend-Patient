import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontendpatient/models/auth/auth_response.dart';
import 'package:frontendpatient/models/auth/login_request.dart';
import 'package:frontendpatient/models/auth/register_nutritionist_request.dart';
import 'package:frontendpatient/models/auth/register_patient_request.dart';
import 'package:frontendpatient/models/auth/update_profile.dart';
import 'package:frontendpatient/models/user/nutritionist_model.dart';
import 'package:frontendpatient/models/user/patient_model.dart';
import 'package:frontendpatient/models/user/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/utils/ApiError.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/bff/auth'; // Reemplaza con tu URL
  static const String tokenKey = 'auth_token';

  final http.Client _client = http.Client();

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _saveToken(authResponse.token);
        return authResponse;
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<AuthResponse> registerPatient(RegisterPatientRequest request) async {
    print('🌐 AuthService.registerPatient iniciado');
    print('📍 URL: $baseUrl/register/patient');

    try {
      print('📝 Preparando datos para envío...');
      final requestBody = json.encode(request.toJson());
      print('📤 Datos a enviar: $requestBody');

      print('🔗 Realizando petición HTTP POST...');
      final response = await _client.post(
        Uri.parse('$baseUrl/register/patient'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('📨 Respuesta recibida');
      print('📊 Status Code: ${response.statusCode}');
      print('📋 Headers: ${response.headers}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Registro exitoso - Status 200');

        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        print('🔑 Token extraído: ${authResponse.token.substring(0, 20)}...');

        print('💾 Guardando token...');
        await _saveToken(authResponse.token);
        print('✅ Token guardado exitosamente');

        return authResponse;
      } else {
        print('❌ Error del servidor - Status: ${response.statusCode}');

        try {
          final error = ApiError.fromJson(json.decode(response.body));
          print('💬 Mensaje de error del API: ${error.message}');
          throw Exception(error.message);
        } catch (parseError) {
          print('❌ Error parseando respuesta de error: $parseError');
          print('📄 Respuesta cruda: ${response.body}');
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } on SocketException catch (e) {
      print('🌐 Error de conexión (SocketException): $e');
      throw Exception('Sin conexión a internet: $e');
    } on TimeoutException catch (e) {
      print('⏰ Timeout de conexión: $e');
      throw Exception('Timeout de conexión: $e');
    } on FormatException catch (e) {
      print('📝 Error de formato JSON: $e');
      throw Exception('Error de formato de datos: $e');
    } catch (e) {
      print('💥 Error inesperado en registerPatient: $e');
      print('📍 Tipo de error: ${e.runtimeType}');
      print('📚 Stack trace: ${StackTrace.current}');

      throw Exception('Error de conexión: $e');
    }
  }

  Future<AuthResponse> registerNutritionist(RegisterNutritionistRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register/nutritionist'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _saveToken(authResponse.token);
        return authResponse;
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token no encontrado');

      final response = await _client.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error obteniendo profile: $e');
    }
  }

  Future<Patient> updatePatientProfile(UpdatePatientProfileRequest request) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token no encontrado');

      final response = await _client.put(
        Uri.parse('$baseUrl/profile/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Patient.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error actualizando profile: $e');
    }
  }

  Future<Nutritionist> updateNutritionistProfile(UpdateNutritionistProfileRequest request) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token no encontrado');

      final response = await _client.put(
        Uri.parse('$baseUrl/profile/nutritionist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Nutritionist.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error actualizando profile: $e');
    }
  }

  Future<void> logout() async {
    await _removeToken();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}