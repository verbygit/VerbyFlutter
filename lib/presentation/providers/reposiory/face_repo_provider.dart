import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/dao/face_dao.dart';
import 'package:verby_flutter/data/data_source/local/database_helper.dart';
import 'package:verby_flutter/domain/repositories/face_repository.dart';
import 'package:verby_flutter/data/repositories/face_repository_impl.dart';

final faceRepoProvider = Provider<FaceRepository>((ref) {
  return FaceRepositoryImpl(FaceDao(DatabaseHelper()));
});
