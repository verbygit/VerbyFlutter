import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/dao/face_dao.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';
import 'package:verby_flutter/domain/repositories/face_repository.dart';

class FaceRepositoryImpl implements FaceRepository {
  final FaceDao _faceDao;

  FaceRepositoryImpl(this._faceDao);

  @override
  Future<Either<String, void>> saveFace(FaceModel face) async {
    try {
      await _faceDao.insertFace(face);
      return const Right(null);
    } catch (e) {
      return Left('Failed to save face: $e');
    }
  }

  @override
  Future<Either<String, FaceModel?>> getFaceByEmployeeId(String employeeId) async {
    try {
      final face = await _faceDao.getFaceByEmployeeId(employeeId);
      return Right(face);
    } catch (e) {
      return Left('Failed to get face by employee ID: $e');
    }
  }

  @override
  Future<Either<String, FaceModel?>> getFaceById(String faceId) async {
    try {
      final face = await _faceDao.getFaceById(faceId);
      return Right(face);
    } catch (e) {
      return Left('Failed to get face by ID: $e');
    }
  }

  @override
  Future<Either<String, List<FaceModel>>> getAllFaces() async {
    try {
      final faces = await _faceDao.getAllFaces();
      return Right(faces);
    } catch (e) {
      return Left('Failed to get all faces: $e');
    }
  }

  @override
  Future<Either<String, List<FaceModel>>> getActiveFaces() async {
    try {
      final faces = await _faceDao.getActiveFaces();
      return Right(faces);
    } catch (e) {
      return Left('Failed to get active faces: $e');
    }
  }

  @override
  Future<Either<String, void>> updateFace(FaceModel face) async {
    try {
      await _faceDao.updateFace(face);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update face: $e');
    }
  }

  @override
  Future<Either<String, void>> updateLastUsed(String employeeId) async {
    try {
      await _faceDao.updateLastUsed(employeeId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update last used timestamp: $e');
    }
  }

  @override
  Future<Either<String, void>> deactivateFace(String employeeId) async {
    try {
      await _faceDao.deactivateFace(employeeId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to deactivate face: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteFace(String employeeId) async {
    try {
      await _faceDao.deleteFace(employeeId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete face: $e');
    }
  }

  @override
  Future<Either<String, bool>> faceExists(String employeeId) async {
    try {
      final exists = await _faceDao.faceExists(employeeId);
      return Right(exists);
    } catch (e) {
      return Left('Failed to check if face exists: $e');
    }
  }

  @override
  Future<Either<String, int>> getFaceCount() async {
    try {
      final count = await _faceDao.getFaceCount();
      return Right(count);
    } catch (e) {
      return Left('Failed to get face count: $e');
    }
  }

  @override
  Future<Either<String, int>> getActiveFaceCount() async {
    try {
      final count = await _faceDao.getActiveFaceCount();
      return Right(count);
    } catch (e) {
      return Left('Failed to get active face count: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteAllFaces() async {
    try {
      await _faceDao.deleteAllFaces();
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete all faces: $e');
    }
  }
}
