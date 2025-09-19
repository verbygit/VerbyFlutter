import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:verby_flutter/data/data_source/local/database_helper.dart';
import 'package:verby_flutter/domain/entities/states/login_state.dart';

import '../../utils/helper_functions.dart';
import '../providers/login_provider.dart';
import '../screens/loader_screen.dart';
import '../widgets/error_box.dart';

class AuthenticationDialog extends ConsumerStatefulWidget {
  final bool shouldClearAllData;

  const AuthenticationDialog({super.key, required this.shouldClearAllData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AuthenticationDialogState();
  }
}

class _AuthenticationDialogState extends ConsumerState<AuthenticationDialog> {
  bool _obscureText = true; // Flag for showing/hiding password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasNavigated = false;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoaderScreen(),
        opaque: false,
        barrierDismissible: false,
      ),
    );
    if (widget.shouldClearAllData) {
      await DatabaseHelper().clearAllTablesExcept();
    }
    await ref.read(loginProvider.notifier).login(email, password);

    Navigator.pop(context,true);
  }


  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Handle navigation only once when signed in
    if (loginState.isSignedIn && !_hasNavigated) {
      _hasNavigated = true;
      if (kDebugMode) {
        print("loginState.isSignedIn ${loginState.isSignedIn}");
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(loginProvider.notifier).resetLogin();
          Navigator.pop(context, true);
        }
      });
    }

    return WillPopScope(
      onWillPop: () async {
        if (!widget.shouldClearAllData) {
          SystemNavigator.pop();
        }
        return widget.shouldClearAllData;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 15,
        child: ScaffoldMessenger(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(30.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "authentication".tr(),
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      20.verticalSpace,

                      if (loginState.error?.isNotEmpty == true)
                        ErrorBox(loginState.error ?? ""),
                      TextFormField(
                        focusNode: _focusNode,
                        controller: _emailController,
                        maxLength: 255,
                        style: TextStyle(fontSize: 16.sp, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "email".tr(),
                          counterText: "",
                        ),

                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          String pattern =
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      20.verticalSpace,
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        // Obscure the text for password
                        style: TextStyle(fontSize: 16.sp, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "password".tr(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              size: 15.w,
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText =
                                    !_obscureText; // Toggle visibility
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      40.verticalSpace,
                      ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 40.w,
                          ),
                          child: Text(
                            "login".tr().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // if (loginState?.isLoading == true)
              // Positioned.fill(
              //   child: Center(
              //     child: Lottie.asset(
              //       "assets/animation/loading_animation.json",
              //       width: 150,
              //       height: 150,
              //       fit: BoxFit.contain,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
