import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/domain/repositories/depa_restant_local_repository.dart';

class InsertDepaRestantsUseCase {
  final DepaRestantLocalRepository planLocalRepository;

  InsertDepaRestantsUseCase(this.planLocalRepository);

  Future<void> call(List<DepaRestantModel> depaRestants) async {
    await planLocalRepository.insetDepaRestants(depaRestants);
  }
}
