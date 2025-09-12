import '../../repositories/employee_local_repository.dart';

class DeleteActionStateUseCase {
  final EmployeeLocalRepository repository;

  DeleteActionStateUseCase(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteEmpActionState(id);
  }
}
