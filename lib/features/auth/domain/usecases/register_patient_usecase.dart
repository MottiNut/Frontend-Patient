import 'package:frontendpatient/features/auth/domain/models/register_patient_request.dart';
import 'package:frontendpatient/features/auth/domain/models/auth_response.dart';
import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';

class RegisterPatientUseCase {
  final AuthRepository repository;

  RegisterPatientUseCase(this.repository);

  Future<AuthResponse> call({
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
    return await repository.registerPatient(request);
  }
}