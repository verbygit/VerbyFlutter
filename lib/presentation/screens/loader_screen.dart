import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../theme/colors.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38, // semi-transparent or solid
      body: Center(
        child:  SpinKitFadingCube(
          color: MColors().crimsonRed,
          size: 100.0.r,
          duration: Duration(milliseconds: 1000),
        ),
      ),
    );
  }
}
