import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';

abstract class FaceRepository {
  /// Save a face to the database
  Future<Either<String, void>> saveFace(FaceModel face);

  /// Get face by employee ID
  Future<Either<String, FaceModel?>> getFaceByEmployeeId(String employeeId);

  /// Get face by face ID
  Future<Either<String, FaceModel?>> getFaceById(String faceId);

  /// Get all faces
  Future<Either<String, List<FaceModel>>> getAllFaces();

  /// Get all active faces
  Future<Either<String, List<FaceModel>>> getActiveFaces();

  /// Update face
  Future<Either<String, void>> updateFace(FaceModel face);

  /// Update last used timestamp
  Future<Either<String, void>> updateLastUsed(String employeeId);

  /// Deactivate face (soft delete)
  Future<Either<String, void>> deactivateFace(String employeeId);

  /// Delete face permanently
  Future<Either<String, void>> deleteFace(String employeeId);

  /// Check if face exists for employee
  Future<Either<String, bool>> faceExists(String employeeId);

  /// Get face count
  Future<Either<String, int>> getFaceCount();

  /// Get active face count
  Future<Either<String, int>> getActiveFaceCount();

  /// Delete all faces (for debug purposes)
  Future<Either<String, void>> deleteAllFaces();
}
