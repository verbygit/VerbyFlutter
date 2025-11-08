import 'package:verby_flutter/domain/repositories/depa_restant_local_repository.dart';

class DeleteDepaRestantsByEmpUseCase {
  final DepaRestantLocalRepository repository;

  DeleteDepaRestantsByEmpUseCase(this.repository);

  Future<bool> call(String empId) async {
    return await repository.deleteDepaRestantsByEmpId(empId);
  }
}
