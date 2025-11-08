import 'package:dartz/dartz.dart';
import 'package:verby_flutter/domain/repositories/face_repository.dart';

class DeleteFaceUseCase {
  final FaceRepository _repository;

  DeleteFaceUseCase(this._repository);

  Future<Either<String, void>> call(String employeeID) async {
    return await _repository.deleteFace(employeeID);
  }
}
