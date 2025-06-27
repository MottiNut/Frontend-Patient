import 'dart:io';
import 'dart:typed_data';
import 'package:frontendpatient/features/auth/domain/models/auth_response.dart';
import 'package:frontendpatient/features/auth/domain/models/login_request.dart';
import 'package:frontendpatient/features/auth/domain/models/register_patient_request.dart';
import 'package:frontendpatient/features/auth/domain/models/update_profile.dart';
import 'package:frontendpatient/features/auth/data/entities/patient.dart';
import 'package:frontendpatient/features/auth/data/entities/user.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> registerPatient(RegisterPatientRequest request);
  Future<User> getCurrentUser();
  Future<Patient> updatePatientProfile(UpdatePatientProfileRequest request);
  Future<Patient> updatePatientProfileImage(File? imageFile);
  Future<Uint8List?> getPatientProfileImage(int userId);
  Future<void> logout();
  Future<String?> getToken();
  Future<bool> isLoggedIn();
}