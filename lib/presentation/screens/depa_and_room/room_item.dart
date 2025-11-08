import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';
import 'package:verby_flutter/domain/entities/room_status.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';

Widget roomItem(DepaRestantModel? depaRestant,Color color,void Function()? onClick) {

  print("roomItem==================> ${color}");
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap:onClick,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(6.r),
        child: Text(
          depaRestant?.name ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            color: MColors().white,
          ),
        ),
      ),
    ),
  );
}

Widget roomCheckListItem(DepaRestant? depaRestant,Color color,void Function()? onClick) {

  print("roomItem==================> ${color}");
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap:onClick,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(6.r),
        child: Center(
          child: Text(
            depaRestant?.name ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: MColors().white,
            ),
          ),
        ),
      ),
    ),
  );
}
