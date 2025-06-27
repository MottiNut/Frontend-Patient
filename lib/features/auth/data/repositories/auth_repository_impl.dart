import 'dart:io';
import 'dart:typed_data';
import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontendpatient/features/auth/domain/models/auth_response.dart';
import 'package:frontendpatient/features/auth/domain/models/login_request.dart';
import 'package:frontendpatient/features/auth/domain/models/register_nutritionist_request.dart';
import 'package:frontendpatient/features/auth/domain/models/register_patient_request.dart';
import 'package:frontendpatient/features/auth/domain/models/update_profile.dart';
import 'package:frontendpatient/features/auth/data/entities/nutritionist.dart';
import 'package:frontendpatient/features/auth/data/entities/patient.dart';
import 'package:frontendpatient/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontendpatient/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:frontendpatient/features/auth/data/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await remoteDataSource.login(request);
    await localDataSource.saveToken(response.token);
    return response;
  }

  @override
  Future<AuthResponse> registerPatient(RegisterPatientRequest request) async {
    final response = await remoteDataSource.registerPatient(request);
    await localDataSource.saveToken(response.token);
    return response;
  }

  @override
  Future<User> getCurrentUser() async {
    final token = await localDataSource.getToken();
    if (token == null) throw Exception('Token no encontrado');
    return await remoteDataSource.getCurrentUser(token);
  }

  @override
  Future<Patient> updatePatientProfile(UpdatePatientProfileRequest request) async {
    final token = await localDataSource.getToken();
    if (token == null) throw Exception('Token no encontrado');
    return await remoteDataSource.updatePatientProfile(request, token);
  }

  @override
  Future<Patient> updatePatientProfileImage(File? imageFile) async {
    final token = await localDataSource.getToken();
    if (token == null) throw Exception('Token no encontrado');
    return await remoteDataSource.updatePatientProfileImage(imageFile, token);
  }

  @override
  Future<Uint8List?> getPatientProfileImage(int userId) async {
    final token = await localDataSource.getToken();
    if (token == null) throw Exception('Token no encontrado');
    return await remoteDataSource.getPatientProfileImage(userId, token);
  }

  @override
  Future<void> logout() async {
    await localDataSource.removeToken();
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null;
  }
}