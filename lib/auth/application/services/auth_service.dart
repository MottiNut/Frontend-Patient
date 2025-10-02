import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:frontendpatient/auth/domain/models/auth_response.dart';
import 'package:frontendpatient/auth/data/dtos/login_request.dart';
import 'package:frontendpatient/auth/data/dtos/register_nutritionist_request.dart';
import 'package:frontendpatient/auth/data/dtos/register_patient_request.dart';
import 'package:frontendpatient/auth/data/dtos/update_profile.dart';
import 'package:frontendpatient/auth/domain/models/nutritionist.dart';
import 'package:frontendpatient/auth/domain/models/patient.dart';
import 'package:frontendpatient/auth/domain/models/user.dart';
import 'package:frontendpatient/commons/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import '../../../commons/utils/api_error.dart';
import '../../../commons/utils/response_error.dart';
import '../../presentation/providers/auth_provider.dart';

class AuthService {
  static const String baseUrl = ApiConstants.auth;
  static const String tokenKey = 'auth_token';

  static const String verificationSendEmailEndpoint = '$baseUrl/verification/send/email';
  static const String verificationSendSmsEndpoint = '$baseUrl/verification/send/sms';
  static const String verificationSendWhatsappEndpoint = '$baseUrl/verification/send/whatsapp';
  static const String verificationResendEndpoint = '$baseUrl/verification/resend';
  static const String verificationVerifyEndpoint = '$baseUrl/verification/verify';
  static const String verificationSendEndpoint = '$baseUrl/verification/send';

  final http.Client _client = http.Client();

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      if (authResponse.token != null) {
        await _saveToken(authResponse.token!);
      } else {
        throw Exception("El token es nulo en la respuesta de login/register");
      }

      return authResponse;
    } else {
      handleResponseError(response);
      throw Exception('Error inesperado');
    }
  }

  Future<AuthResponse> registerPatient(RegisterPatientRequest request) async {
    try {
      final jsonData = request.toJson();

      // LOGGING COMPLETO
      print('🔵 ===== DATOS QUE SE ENVÍAN AL BACKEND =====');
      print('📧 Email: ${jsonData['email']}');
      print('🔑 Password length: ${(jsonData['password'] as String).length}');
      print('👤 FirstName: ${jsonData['firstName']}');
      print('👤 LastName: ${jsonData['lastName']}');
      print('📅 BirthDate: ${jsonData['birthDate']}');
      print('📱 Phone: ${jsonData['phone']}');
      print('📏 Height: ${jsonData['height']} (tipo: ${jsonData['height'].runtimeType})');
      print('⚖️ Weight: ${jsonData['weight']} (tipo: ${jsonData['weight'].runtimeType})');
      print('🏥 HasMedicalCondition: ${jsonData['hasMedicalCondition']}');
      print('💊 ChronicDisease: ${jsonData['chronicDisease']}');
      print('🥜 Allergies: ${jsonData['allergies']}');
      print('🍽️ DietaryPreferences: ${jsonData['dietaryPreferences']}');
      print('⚥ Gender: ${jsonData['gender']}');
      print('📤 JSON COMPLETO:');
      print(JsonEncoder.withIndent('  ').convert(jsonData));
      print('================================================');

      final response = await _client.post(
        Uri.parse('$baseUrl/register/patient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      print('📨 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        print('💾 Guardando token...');
        await _saveToken(authResponse.token!);
        return authResponse;
      } else {
        print('❌ Error del servidor - Status: ${response.statusCode}');

        // Analizar el error
        try {
          final errorData = json.decode(response.body);
          print('❌ Error data: $errorData');

          String errorMessage = errorData['message'] ?? 'Error desconocido';

          // Si hay detalles del error, mostrarlos
          if (errorData['errors'] != null) {
            print('❌ Detalles del error: ${errorData['errors']}');
          }

          throw Exception(errorMessage);
        } catch (parseError) {
          if (parseError is Exception) {
            rethrow;
          }
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Sin conexión a internet');
    } on TimeoutException catch (e) {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
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
        await _saveToken(authResponse.token!);
        return authResponse;
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // MÉTODO CORREGIDO - Detecta automáticamente el content-type
  Future<Patient> updatePatientProfileImage(File? imageFile) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token no encontrado');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/patient/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Solo agregar el archivo si no es null
      if (imageFile != null) {
        // Detectar el MIME type automáticamente
        final mimeType = lookupMimeType(imageFile.path);

        // Validar que sea una imagen
        if (mimeType == null || !mimeType.startsWith('image/')) {
          throw Exception('El archivo seleccionado no es una imagen válida');
        }

        // Crear el MultipartFile con el content-type correcto
        final multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType), // Especificar el content-type
        );

        request.files.add(multipartFile);

        print('📤 Subiendo imagen con content-type: $mimeType');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📨 Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Imagen actualizada exitosamente');
        return Patient.fromJson(json.decode(response.body));
      } else {
        print('❌ Error del servidor: ${response.body}');
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      print('💥 Error en updatePatientProfileImage: $e');
      throw Exception('Error actualizando imagen de perfil: $e');
    }
  }

  // Nuevo método para obtener imagen
  Future<Uint8List?> getPatientProfileImage(int userId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token no encontrado');

      final response = await _client.get(
        Uri.parse('$baseUrl/profile/patient/$userId/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        return null; // No tiene imagen
      } else {
        throw Exception('Error obteniendo imagen');
      }
    } catch (e) {
      throw Exception('Error obteniendo imagen: $e');
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

  /// Enviar código de verificación
  Future<AuthResponse> sendVerificationCode({
    required String email,
    required VerificationMethod method,
    String? phoneNumber,
  }) async {
    try {
      String endpoint;
      Map<String, dynamic> requestBody = {
        'email': email,
      };

      // Seleccionar el endpoint correcto según el método
      switch (method) {
        case VerificationMethod.email:
          endpoint = verificationSendEmailEndpoint;
          break;
        case VerificationMethod.sms:
          endpoint = verificationSendSmsEndpoint;
          requestBody['phoneNumber'] = phoneNumber;
          break;
        case VerificationMethod.whatsapp:
          endpoint = verificationSendWhatsappEndpoint;
          requestBody['phoneNumber'] = phoneNumber;
          break;
      }

      if (phoneNumber != null) debugPrint('📤 Teléfono: $phoneNumber');

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Error enviando código',
        );
      }
    } catch (e) {

      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(verificationVerifyEndpoint),
        headers: _headers,
        body: json.encode({
          'code': code,
          'type': 'email', // O el tipo correspondiente
          'email': email,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Código inválido',
        );
      }
    } catch (e) {

      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  /// Reenviar código de verificación
  Future<bool> resendVerificationCode({
    required String email,
  }) async {
    try {
      print('🔄 Reenviando código de verificación');
      print('📧 Email: $email');

      final response = await _client.post(
        Uri.parse('$baseUrl/verification/resend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'type': 'email',
        }),
      );

      print('📨 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Código reenviado exitosamente');
        return true;
      } else {
        print('❌ Error reenviando código');
        try {
          final error = ApiError.fromJson(json.decode(response.body));
          throw Exception(error.message);
        } catch (parseError) {
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('💥 Error en resendVerificationCode: $e');
      throw Exception('Error reenviando código: $e');
    }
  }

}