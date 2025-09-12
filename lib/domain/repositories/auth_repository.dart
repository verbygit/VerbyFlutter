import 'package:dartz/dartz.dart';
import '../../data/models/remote/login_response_model.dart';
import '../core/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(
    String email,
    String password,
  );

  Future<Either<Failure, bool>> checkPassword(String deviceID, String password);
}
