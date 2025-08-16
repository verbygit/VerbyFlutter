import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

final ThemeData theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: MColors().colorPrimary,
    // brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.sp, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: TextStyle(
        fontFamily: 'BalooDa2',
        fontSize: 30.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black),
    titleSmall:
        TextStyle(fontFamily: 'BalooDa2', fontSize: 14.sp, color: Colors.black),
    titleMedium: TextStyle(
        fontFamily: 'BalooDa2',
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black),
    bodyMedium: const TextStyle(fontFamily: 'BalooDa2', color: Colors.black),
    bodySmall: const TextStyle(fontFamily: 'BalooDa2', color: Colors.black),
    displaySmall: const TextStyle(fontFamily: 'BalooDa2', color: Colors.black),
  ),
);
