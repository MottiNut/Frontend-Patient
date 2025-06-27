import 'package:frontendpatient/features/auth/domain/models/update_profile.dart';
import 'package:frontendpatient/features/auth/data/entities/patient.dart';
import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';

class UpdatePatientProfileUseCase {
  final AuthRepository repository;

  UpdatePatientProfileUseCase(this.repository);

  Future<Patient> call(UpdatePatientProfileRequest request) async {
    return await repository.updatePatientProfile(request);
  }
}