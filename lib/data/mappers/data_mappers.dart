import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';
import 'package:verby_flutter/domain/entities/room_status.dart';

extension DepRestantMapperExtenetion on DepaRestant {
  DepaRestantModel toDepaRestantModel(
    String employeeID,
    bool isDepa,
    int roomStatus,
  ) {
    status = roomStatus;
    return DepaRestantModel(employeeID, isDepa, this);
  }
}
