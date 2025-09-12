import 'package:dartz/dartz.dart';
import '../../../data/models/remote/login_response_model.dart';
import '../../core/failure.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, LoginResponseModel>> call(
    String email,
    String password,
  ) async {
    return await repository.login(email, password);
  }
}
