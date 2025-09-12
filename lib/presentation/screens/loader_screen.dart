import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38, // semi-transparent or solid
      body: Center(
        child: Lottie.asset(
          'assets/animation/loading_animation.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
