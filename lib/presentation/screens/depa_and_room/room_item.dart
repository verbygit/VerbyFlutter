import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/domain/entities/room_status.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';

Widget roomItem(DepaRestantModel? depaRestant) {
  final bgColor = switch (RoomStatus.getRoomStatus(
    depaRestant?.status ?? 0,
  )) {
    RoomStatus.DEFAULT => MColors().mediumDarkGray,
    RoomStatus.CLEANED => MColors().freshGreen,
    RoomStatus.REDCARCD => MColors().crimsonRed,
    RoomStatus.VOLUNTER => MColors().chartreuse,
  };
  return Container(
    padding: EdgeInsets.all(6.r),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      depaRestant?.name ?? "",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24.sp,
        color: MColors().white,
      ),
    ),
  );
}
