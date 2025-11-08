import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/domain/repositories/plan_local_repository.dart';

class InsertPlansUseCase {
  final PlanLocalRepository planLocalRepository;

  InsertPlansUseCase(this.planLocalRepository);

  Future<void> call(List<Plan> plans) async {
    await planLocalRepository.insetPlans(plans);
  }
}
