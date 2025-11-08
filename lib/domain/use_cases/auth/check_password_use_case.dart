import 'package:dartz/dartz.dart';
import 'package:verby_flutter/domain/repositories/auth_repository.dart';

import '../../core/failure.dart';

class CheckPassword {
  final AuthRepository authRepository;

  CheckPassword(this.authRepository);

  Future<Either<Failure, bool>> call(String deviceID, String password) async {
    return authRepository.checkPassword(deviceID, password);
  }
}
