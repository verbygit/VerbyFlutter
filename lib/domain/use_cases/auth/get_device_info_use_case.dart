import 'package:dartz/dartz.dart';
import '../../../data/models/remote/device_response.dart';
import '../../../data/models/remote/login_response_model.dart';
import '../../core/failure.dart';
import '../../repositories/auth_repository.dart';

class GetDeviceInfoUseCase {
  final AuthRepository repository;

  GetDeviceInfoUseCase(this.repository);

  Future<Either<Failure, DeviceResponse>> call(
    String deviceId
  ) async {
    return await repository.getDeviceInfo(deviceId);
  }
}
