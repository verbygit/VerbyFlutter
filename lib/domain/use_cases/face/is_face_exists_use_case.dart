import 'package:dartz/dartz.dart';
import 'package:verby_flutter/domain/repositories/face_repository.dart';

class IsFaceExistsUseCase {
  final FaceRepository _repository;

  IsFaceExistsUseCase(this._repository);

  Future<Either<String, bool>> call(String employeeID) async {
    return await _repository.faceExists(employeeID);
  }
}
