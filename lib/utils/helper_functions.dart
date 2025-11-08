import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../presentation/theme/colors.dart';

showSnackBar(String text, BuildContext context) {
  print("show toast =============> $text");

  showToast(
    text,
    position: StyledToastPosition.center,
    context: context,
    backgroundColor: MColors().freshGreen90,
    borderRadius: BorderRadius.circular(10),
    textPadding: EdgeInsets.all(30.w),
    textStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22.sp,
      color: Colors.white,
    ),
    textAlign: TextAlign.center,
    animDuration: Duration.zero,
  );
}

showErrorSnackBar(String text, BuildContext context) {
  showToast(
    text,
    position: StyledToastPosition.center,
    context: context,
    backgroundColor: MColors().crimsonRed90,
    borderRadius: BorderRadius.circular(10),
    textPadding: EdgeInsets.all(30.w),
    textStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22.sp,
      color: Colors.white,
    ),
    animDuration: Duration.zero,
  );
}

bool isDigits(String s) => RegExp(r'^\d+$').hasMatch(s);
