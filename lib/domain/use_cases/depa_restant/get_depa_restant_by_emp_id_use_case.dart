import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/domain/repositories/depa_restant_local_repository.dart';

class GetDepaRestantByEmpIdUseCase {
  final DepaRestantLocalRepository _repository;

  GetDepaRestantByEmpIdUseCase(this._repository);

  Future<Either<String, List<DepaRestantModel>?>> call(String id, bool isDepa) async {
    return await _repository.getDepaRestantByEmployeeId(id, isDepa);
  }
}
