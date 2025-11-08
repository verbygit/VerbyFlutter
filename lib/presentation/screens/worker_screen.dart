import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:verby_flutter/presentation/dialog/authentication_dialog.dart';
import 'package:verby_flutter/presentation/dialog/pin_dialog.dart';
import 'package:verby_flutter/presentation/providers/shared_pref_provider.dart';
import 'package:verby_flutter/presentation/providers/worker_screen_provider.dart';
import 'package:verby_flutter/presentation/screens/face_verification_screen.dart';
import 'package:verby_flutter/presentation/screens/select_operation_screen.dart';
import 'package:verby_flutter/presentation/screens/setting_screen.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:verby_flutter/presentation/widgets/text_clock.dart';
import 'package:verby_flutter/utils/helper_functions.dart';
import '../providers/login_provider.dart';
import '../providers/lock_task_provider.dart';
import '../widgets/no_internet_design.dart';

class WorkerScreen extends ConsumerStatefulWidget {
  const WorkerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _WorkerScreen();
  }
}

class _WorkerScreen extends ConsumerState<WorkerScreen> {
  final employeeIDController = TextEditingController();
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    ref.read(workerScreenProvider.notifier).listenToInternetStatus();
    _checkUserAndShowDialog();
  }

  void _checkUserAndShowDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserExist();
    });
  }

  void _checkUserExist() async {
    if (!mounted) return;

    try {
      final sharedPrefsAsync = ref.read(sharedPreferencesProvider);

      final result = await sharedPrefsAsync.when(
        data: (helper) async {
          var user = helper.getUser();
          return user;
        },
        loading: () async {
          await Future.delayed(Duration(milliseconds: 50));
          if (!mounted) return null;

          final retryPrefs = ref.read(sharedPreferencesProvider);
          return retryPrefs.when(
            data: (helper) => helper.getUser(),
            loading: () => null,
            error: (_, __) => null,
          );
        },
        error: (error, stack) async {
          if (kDebugMode) {
            print('SharedPreferences error: $error');
          }
          return null;
        },
      );

      if (result == null && mounted) {
        _showAuthenticationDialog();
      } else {
        ref.read(workerScreenProvider.notifier).saveUser(result!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user: $e');
      }
    }
  }

  void _showAuthenticationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AuthenticationDialog(shouldClearAllData: false);
      },
    );
    if (result != null) {
      _checkUserExist();
      await Future.delayed(Duration(milliseconds: 100));
      ref.read(workerScreenProvider.notifier).getEmployees();
    }
  }

  void _syncData() {
    print("_syncData======================> invoked");
    ref.read(workerScreenProvider.notifier).syncData();
  }

  void navigateToSetting() async {
    HapticFeedback.heavyImpact();
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return PasswordDialog();
    //   },
    // );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingScreen()),
    );

    if (result != null) {
      _checkUserExist();
      await Future.delayed(Duration(milliseconds: 100));
      ref.read(workerScreenProvider.notifier).getEmployees();
    }
    ref.read(workerScreenProvider.notifier).setSharedPreferencesHelper();
  }

  void _showPinDialog()async {
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 200));

    _focusNode?.unfocus();
    if (ref.read(workerScreenProvider).isSyncing) {
      showErrorSnackBar("data_syncing".tr(), context);
      return;
    }
    if (employeeIDController.text.isEmpty) {
      ref.read(workerScreenProvider.notifier).setErrorMessage("not_valid".tr());
      return;
    }
    final employee = ref
        .read(workerScreenProvider.notifier)
        .getEmployeeById(int.parse(employeeIDController.text));
    if (employee != null) {
      employeeIDController.text = "";
      showPinDialog(context, employee, (onPinSuccess) async {
        if (onPinSuccess) {
          Widget? widget;
          if (ref.read(workerScreenProvider).isFaceIdForAll) {
            final face = await ref
                .read(workerScreenProvider.notifier)
                .getFaceByEmpId(employee.id ?? -1);
            if (face == null) {
              ref
                  .read(workerScreenProvider.notifier)
                  .setErrorMessage("missing_face".tr());
            } else {
              widget = FaceVerificationScreen(employee: employee);
            }
          } else if (ref.read(workerScreenProvider).isFaceForRegisterFace) {
            final face = await ref
                .read(workerScreenProvider.notifier)
                .getFaceByEmpId(employee.id ?? -1);

            if (face == null) {
              widget = SelectOperationScreen(employee: employee);
            } else {
              widget = FaceVerificationScreen(employee: employee);
            }
          } else {
            widget = SelectOperationScreen(employee: employee);
          }

          if (widget != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => widget!),
            );
            if (result != null) {
              _syncData();
            }
          }
        } else {
          ref
              .read(workerScreenProvider.notifier)
              .setErrorMessage("incorrect_pin".tr());
        }
      });
    } else {
      ref.read(loginProvider.notifier).setMessage("resync_server".tr());
    }
  }

  void _showGuidedAccessInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('enable_guided_access'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('to_enable_app_pinning'.tr()),
              SizedBox(height: 10),
              Text("pinning_option_one".tr()),
              Text('pinning_option_two'.tr()),
              Text('pinning_option_three'.tr()),
              Text('pinning_option_four'.tr()),
              SizedBox(height: 10),
              Text('pinning_option_five'.tr()),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop();
              },
              child: Text('ok'.tr(), style: TextStyle(color: Colors.white)),
            ),

            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            //   onPressed: (){
            //     HapticFeedback.heavyImpact();
            //   openAppSettings();
            // }, child: Text('Open Settings',style: TextStyle(color: Colors.white),),),
          ],
        );
      },
    );
  }

  //
  // void _openGuidedAccessSettings() async {
  //   HapticFeedback.heavyImpact();
  //   // Try multiple iOS settings URL schemes
  //   final settingsUrls = [
  //     'App-Prefs:ACCESSIBILITY',
  //     'App-Prefs:root=ACCESSIBILITY',
  //     'prefs:root=ACCESSIBILITY',
  //   ];
  //
  //   bool opened = false;
  //   for (String url in settingsUrls) {
  //     try {
  //       if (await canLaunchUrl(Uri.parse(url))) {
  //         await launchUrl(Uri.parse(url));
  //         opened = true;
  //         break;
  //       }
  //     } catch (e) {
  //       print('Failed to open $url: $e');
  //       continue;
  //     }
  //   }
  //
  //   if (!opened) {
  //     // Fallback: show instructions dialog
  //     _showGuidedAccessInstructions();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final workerScreenState = ref.watch(workerScreenProvider);

    ref.listen(workerScreenProvider, (previous, next) {
      if ((previous?.employees == null ||
              previous?.employees?.isEmpty == true) &&
          (next.employees != null && next.employees!.isNotEmpty)) {
        _syncData();
      }

      if (next.message.isNotEmpty) {
        showSnackBar(next.message, context);
        ref.read(workerScreenProvider.notifier).setMessage("");
      }
      if (next.errorMessage.isNotEmpty) {
        showErrorSnackBar(next.errorMessage, context);
        ref.read(workerScreenProvider.notifier).setErrorMessage("");
      }

      if ((previous?.isInternetConnected == false &&
          next.isInternetConnected)) {
        _syncData();
      }
    });

    return GestureDetector(
      onTap: () {
        _focusNode?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 60.h,
                    decoration: BoxDecoration(color: MColors().darkGrey),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          child: TextClockWidget(),
                        ),
                        Text(
                          workerScreenState.userModel?.deviceName ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        workerScreenState.isInternetConnected
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 10.h,
                                ),
                                child: Image.asset(
                                  'assets/images/ic_green_indicator.png',
                                  width: 40.w,
                                  height: 40.h,
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 10.h,
                                ),
                                child: SpinKitDoubleBounce(color: Colors.red),
                              ),
                        // Lottie.asset(
                        //         "assets/animation/offline_animation.json",
                        //         width: 60.w,
                        //         fit: BoxFit.fill,
                        //       ),
                      ],
                    ),
                  ),
                  if (!workerScreenState.isInternetConnected) noInternetText(),
                  //the last container
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          10.verticalSpace,
                          Text(
                            "enter_your_id".tr(),
                            style: TextStyle(
                              fontSize: 30.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          20.verticalSpace,

                          Container(
                            width: 150.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.black,
                                width: 2.w,
                              ),
                            ),
                            child: TextField(
                              focusNode: _focusNode,
                              controller: employeeIDController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30.sp,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                // hintText: "enter_your_id".tr(),
                                border: InputBorder.none,
                                counterText: "",
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          30.verticalSpace,

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 70.r),

                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:_showPinDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:MColors().blue,
                                  splashFactory: InkRipple.splashFactory,
                                  overlayColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 15.r),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),

                                ),
                                // borderRadius: BorderRadius.circular(15.r),
                                child: Text(
                                  "submit_button".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: SvgPicture.asset(
                                  'assets/svg/verby_logo.svg',
                                  // width: double.infinity,
                                  height: 210.r,
                                  // fit: BoxFit.fill,
                                ),
                              ),

                              Positioned(
                                bottom: 20.r,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Powered\nby",
                                      style: TextStyle(
                                        color: MColors().lightGrey,
                                        fontSize: 10.sp,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    5.horizontalSpace,
                                    Image.asset(
                                      'assets/images/verbica_logo.webp',
                                      height: 20.r,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: navigateToSetting,
                                icon: SvgPicture.asset(
                                  'assets/svg/ic_settings.svg',
                                  colorFilter: ColorFilter.mode(
                                    MColors().lightGrey,
                                    BlendMode
                                        .srcIn, // Apply the tint to the entire SVG
                                  ),
                                  width: 35.w,
                                  height: 35.h,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  if (Platform.isAndroid) {
                                    ref
                                        .read(lockTaskProvider.notifier)
                                        .toggleLockTask();
                                  } else {
                                    _showGuidedAccessInstructions();
                                  }
                                },
                                icon: SvgPicture.asset(
                                  'assets/svg/ic_lock_open.svg',
                                  colorFilter: ColorFilter.mode(
                                    MColors().lightGrey,
                                    BlendMode.srcIn,
                                  ),
                                  width: 35.w,
                                  height: 35.h,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Version 0.0.0",
                            style: TextStyle(
                              color: MColors().lightGrey,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    employeeIDController.dispose();
    super.dispose();
  }
}
