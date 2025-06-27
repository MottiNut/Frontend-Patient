import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:frontendpatient/features/auth/domain/models/auth_response.dart';
import 'package:frontendpatient/features/auth/domain/models/login_request.dart';
import 'package:frontendpatient/features/auth/domain/models/register_patient_request.dart';
import 'package:frontendpatient/features/auth/domain/models/update_profile.dart';
import 'package:frontendpatient/features/auth/data/entities/patient.dart';
import 'package:frontendpatient/features/auth/data/entities/user.dart';
import 'package:frontendpatient/shared/constants/api_constants.dart';
import 'package:frontendpatient/shared/utils/ApiError.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> registerPatient(RegisterPatientRequest request);
  Future<User> getCurrentUser(String token);
  Future<Patient> updatePatientProfile(UpdatePatientProfileRequest request, String token);
  Future<Patient> updatePatientProfileImage(File? imageFile, String token);
  Future<Uint8List?> getPatientProfileImage(int userId, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String baseUrl = ApiConstants.auth;
  final http.Client _client = http.Client();

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<AuthResponse> registerPatient(RegisterPatientRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register/patient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
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

  @override
  Future<Uint8List?> getPatientProfileImage(int userId, String token) async {
    try {
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
        return null;
      } else {
        throw Exception('Error obteniendo imagen');
      }
    } catch (e) {
      throw Exception('Error obteniendo imagen: $e');
    }
  }

  @override
  Future<Patient> updatePatientProfile(UpdatePatientProfileRequest request, String token) async {
    try {
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
      throw Exception('Error actualizando perfil del paciente: $e');
    }
  }


  @override
  Future<Patient> updatePatientProfileImage(File? imageFile, String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/patient/image'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (imageFile != null) {
        final mimeType = lookupMimeType(imageFile.path);
        if (mimeType == null || !mimeType.startsWith('image/')) {
          throw Exception('El archivo no es una imagen válida');
        }

        final multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return Patient.fromJson(json.decode(response.body));
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.message);
      }
    } catch (e) {
      throw Exception('Error subiendo imagen de perfil: $e');
    }
  }

}