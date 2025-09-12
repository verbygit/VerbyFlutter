import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ErrorBox(String error) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(10.r),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Text(error, style: TextStyle(color: Colors.white),),
  );

}