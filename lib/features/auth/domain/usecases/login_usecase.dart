import 'package:frontendpatient/features/auth/domain/models/login_request.dart';
import 'package:frontendpatient/features/auth/domain/models/auth_response.dart';
import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponse> call(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    return await repository.login(request);
  }
}