import 'package:flutter/material.dart';

extension ScreenSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;
}

const Set<String> kSubProductIDS = {"puzzler_sub_yearly","puzzler_sub_monthly"};

//UI
int smallDeviceThreshold = 600;
int mediumDeviceThreshold = 720;
int largeDeviceThreshold = 800;

//Strings
String quizCompletedLabel = "Congratulations you’ve\nCompleted this Quiz!";
String playMoreQuizLabel =
    "keep testing your knowledge by playing more quizzes!";
String signUpLabel = "Sign up to unlock the world of X Puzzler";

String emailSentLabel =
    "We’ve sent password reset instructions to your email. Please check your inbox (and spam/junk folder if needed) to proceed with resetting your password. Thank you!";
