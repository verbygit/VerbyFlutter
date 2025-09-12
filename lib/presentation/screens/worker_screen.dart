import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';
import 'package:verby_flutter/domain/core/connectivity_helper.dart';
import 'package:verby_flutter/presentation/dialog/authentication_dialog.dart';
import 'package:verby_flutter/presentation/dialog/password_dialog.dart';
import 'package:verby_flutter/presentation/dialog/pin_dialog.dart';
import 'package:verby_flutter/presentation/providers/shared_pref_provider.dart';
import 'package:verby_flutter/presentation/providers/worker_screen_provider.dart';
import 'package:verby_flutter/presentation/screens/face_verification_screen.dart';
import 'package:verby_flutter/presentation/screens/select_operation_screen.dart';
import 'package:verby_flutter/presentation/screens/setting_screen.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:verby_flutter/presentation/widgets/text_clock.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';
import '../providers/login_provider.dart';

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

  void _showAuthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AuthenticationDialog(
          isLoginSuccess: (isLoginSuccess) async {
            _checkUserExist();
            await Future.delayed(Duration(milliseconds: 100));
            ref.read(workerScreenProvider.notifier).getEmployees();
          },
        );
      },
    );
  }

  void _syncData() {
    if (ref.read(workerScreenProvider).isInternetConnected) {
      final employees = ref.watch(workerScreenProvider).employees;
      final deviceId = ref.read(workerScreenProvider).userModel?.deviceID;

      if (employees != null &&
          employees.isNotEmpty &&
          deviceId != null &&
          deviceId > 0) {
        ref
            .read(workerScreenProvider.notifier)
            .getPlansAndSave(employees, deviceId);
        ref
            .read(workerScreenProvider.notifier)
            .getDepaRestantAndEmployeesStates();
      }
    }
  }

  void _showPinDialog() {
    _focusNode?.unfocus();
    if (employeeIDController.text.isEmpty) {
      ref.read(loginProvider.notifier).setMessage("not_valid".tr());
      return;
    }
    final employee = ref
        .read(workerScreenProvider.notifier)
        .getEmployeeById(int.parse(employeeIDController.text));
    if (employee != null) {
      showPinDialog(context, employee, (onPinSuccess) async {
        if (onPinSuccess) {
          // safeNavigateToScreen(
          //   context,
          //   FaceVerificationScreen(employee: employee),
          // );
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectOperationScreen(employee: employee),
            ),
          );
          _syncData();
        } else {
          ref.read(loginProvider.notifier).setMessage("incorrect_pin".tr());
        }
      });
    } else {
      ref.read(loginProvider.notifier).setMessage("resync_server".tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerScreenState = ref.watch(workerScreenProvider);

    ref.listen(workerScreenProvider, (previous, next) {
      if ((previous?.employees == null ||
              previous?.employees?.isEmpty == true) &&
          (next.employees != null && next.employees!.isNotEmpty)) {
        _syncData();
      }
    });

    return Scaffold(
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
                  height: 56.h,
                  decoration: BoxDecoration(color: MColors().darkGrey),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextClockWidget(),
                      Image.asset(
                        workerScreenState.isInternetConnected
                            ? 'assets/images/ic_green_indicator.png'
                            : 'assets/images/ic_red_indicator.png',
                        width: 40.w,
                        height: 40.h,
                      ),
                    ],
                  ),
                ),

                //the last container
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        30.verticalSpace,
                        Text(
                          "enter_your_id".tr(),
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        25.verticalSpace,

                        Container(
                          width: 150.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.black, width: 2.w),
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

                        ElevatedButton(
                          onPressed: _showPinDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Text(
                              "submit_button".tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                              ),
                            ),
                          ),
                        ),

                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/svg/verby_logo.svg',
                                width: double.infinity,
                                height: 230.h,
                              ),
                            ),

                            Positioned(
                              bottom: 30.h,
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
                                  ),
                                  5.horizontalSpace,
                                  Image.asset(
                                    'assets/images/verbica_logo.webp',
                                    height: 20.w,
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
                              onPressed: () {
                                // showDialog(
                                //   context: context,
                                //   builder: (BuildContext context) {
                                //     return PasswordDialog();
                                //   },
                                // );
                                safeNavigateToScreen(context, SettingScreen());
                              },
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
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                'assets/svg/ic_lock_open.svg',
                                colorFilter: ColorFilter.mode(
                                  MColors().lightGrey,
                                  BlendMode
                                      .srcIn, // Apply the tint to the entire SVG
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
    );
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    employeeIDController.dispose();
    super.dispose();
  }
}
