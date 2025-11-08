import '../../repositories/employee_local_repository.dart';

class DeletePerformanceStateUseCase {
  final EmployeeLocalRepository repository;

  DeletePerformanceStateUseCase(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteEmpPerformanceState(id);
  }
}
