import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38, // semi-transparent or solid
      body: Center(
        child:  SpinKitCubeGrid(
          color: Colors.red,
          size: 100.0.r,
          duration: Duration(milliseconds: 800),
        ),
      ),
    );
  }
}
