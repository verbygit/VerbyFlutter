import 'package:verby_flutter/domain/repositories/depa_restant_local_repository.dart';


class DeleteDepaRestantsUseCase {
  final DepaRestantLocalRepository repository;

  DeleteDepaRestantsUseCase(this.repository);

  Future<bool> call(List<String> ids) async {
    return await repository.deleteDepaRestants(ids);
  }
}
