import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/face/get_all_face_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/face_repo_provider.dart';

import '../../../../domain/use_cases/face/is_face_exists_use_case.dart';

final getAllFacesUseCaseProvider = Provider<GetAllFaceUseCase>((ref) {
  final faceRepositoryProvider = ref.read(faceRepoProvider);
  return GetAllFaceUseCase(faceRepositoryProvider);
});
