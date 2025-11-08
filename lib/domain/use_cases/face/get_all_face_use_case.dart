import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';
import '../../repositories/face_repository.dart';

class GetAllFaceUseCase {
  final FaceRepository _repository;

  GetAllFaceUseCase(this._repository);

  Future<Either<String, List<FaceModel>>> call() async {
    return await _repository.getAllFaces();
  }
}
