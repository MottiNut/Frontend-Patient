import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontendpatient/features/auth/data/entities/user.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User> call() async {
    return await repository.getCurrentUser();
  }
}