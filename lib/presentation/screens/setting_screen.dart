import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/presentation/dialog/indentification_dialog.dart';
import 'package:verby_flutter/presentation/dialog/password_dialog.dart';
import 'package:verby_flutter/presentation/screens/face_registration_screen.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:verby_flutter/presentation/widgets/switch_with_text.dart';
import 'package:verby_flutter/utils/helper_functions.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';
import 'package:verby_flutter/presentation/providers/reposiory/face_repo_provider.dart';

import '../dialog/authentication_dialog.dart';
import '../dialog/delete_face_dialog.dart';
import '../dialog/pin_dialog.dart';
import '../providers/setting_state_provider.dart';
import '../widgets/custom_seekbar.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SettingScreen();
  }
}

class _SettingScreen extends ConsumerState<SettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  void showIdentificationDialog(bool isEditFace) async {
    final buildContext = context;
    final employee = await showDialog<Employee>(
      context: context,
      builder: (context) => IdentificationDialog(),
    );

    if (employee != null) {
      final isFaceExists = await ref
          .read(settingScreenStateProvider.notifier)
          .checkIsFaceExists(employee.id.toString());

      print("is Face exist====> $isFaceExists");

      if (isFaceExists && !isEditFace) {
        showErrorSnackBar("face_id_already_registered".tr(), context);
        return;
      } else if (!isFaceExists && isEditFace) {
        showErrorSnackBar("missing_Face".tr(), context);
        return;
      }

      showPinDialog(buildContext, employee, (isCorrectPin) async {
        if (isCorrectPin) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => FaceRegistrationScreen(employee: employee),
            ),
          );
          if (result == true) {
            ref.read(settingScreenStateProvider.notifier).getAllFaces();
          }
        } else {
          showErrorSnackBar("incorrect_pin".tr(), buildContext);
        }
      });
    }
  }

  void showDeleteFaceDialog() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 100));

    final buildContext = context;
    final employee = await showDialog<Employee>(
      context: buildContext,
      builder: (context) => DeleteFaceDialog(),
    );

    if (employee != null) {
      final isFaceExists = await ref
          .read(settingScreenStateProvider.notifier)
          .checkIsFaceExists(employee.id.toString());

      if (isFaceExists) {
        showPinDialog(buildContext, employee, (isCorrectPin) async {
          if (isCorrectPin) {
            final result = await ref
                .read(settingScreenStateProvider.notifier)
                .deleteFace(employee.id.toString());
            if (result) {
              ref.read(settingScreenStateProvider.notifier).getAllFaces();

              showSnackBar("face_id_deleted".tr(), buildContext);
            } else {
              showErrorSnackBar("not_valid".tr(), buildContext);
            }
          } else {
            showErrorSnackBar("incorrect_pin".tr(), buildContext);
          }
        });
      } else {
        showErrorSnackBar("missing_Face".tr(), buildContext);
        return;
      }
    }
  }

  void setFaceIdForAll(bool value) async {
    HapticFeedback.heavyImpact();

    ref.read(settingScreenStateProvider.notifier).setFaceIDForAll(value);
  }

  void setFaceIdForRegisterFace(bool value) async {
    HapticFeedback.heavyImpact();

    ref
        .read(settingScreenStateProvider.notifier)
        .setFaceIDForRegisterFace(value);
  }

  void _showAuthenticationDialog() async {
    HapticFeedback.heavyImpact();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AuthenticationDialog(shouldClearAllData: true);
      },
    );

    if (result != null) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _uploadArchiveEvent() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 100));

    await ref.read(settingScreenStateProvider.notifier).uploadArchive();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingScreenStateProvider);

    ref.listen(settingScreenStateProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage.isNotEmpty) {
        showErrorSnackBar(next.errorMessage, context);
        ref.read(settingScreenStateProvider.notifier).setErrorMessage('');
      }
      if (previous?.message != next.message && next.message.isNotEmpty) {
        showSnackBar(next.message, context);
        ref.read(settingScreenStateProvider.notifier).setMessage('');
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MColors().darkGrey,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "setting".tr(),

        ),
        titleTextStyle:TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ) ,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: IconButton(
              iconSize: 30.r,
              onPressed: () {
                HapticFeedback.heavyImpact();
                ref.read(settingScreenStateProvider.notifier).syncData();
              },
              icon: Icon(Icons.cloud_download_outlined),
              color: MColors().greenMunsell,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: IconButton(
              iconSize: 30.r,
              onPressed: _showAuthenticationDialog,
              icon: Icon(Icons.key),
              color: MColors().greenMunsell,
            ),
          ),
        ],

        // actionsPadding: EdgeInsets.all(10.r),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                child: Material(
                  color: MColors().veryLightGray,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      20.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.w),
                        child: Text(
                          "face_id_settings".tr(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: TextSwitch(
                          text: "require_face_id_all".tr(),
                          isChecked: state.isFaceIdForAll,
                          onChanged: setFaceIdForAll,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Divider(
                          height: 0.5, // Height of the divider
                          thickness: 0.5, // Thickness of the line
                          color: Colors.grey, // Line color
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: TextSwitch(
                          text: "require_face_auth_opt".tr(),
                          isChecked: state.isFaceForRegisterFace,
                          onChanged: setFaceIdForRegisterFace,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Divider(
                          height: 0.5, // Height of the divider
                          thickness: 0.5, // Thickness of the line
                          color: Colors.grey, // Line color
                        ),
                      ),
                      20.verticalSpace,
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 10.w),
                      //   child: Text(
                      //     "num_of_retries".tr(),
                      //     style: TextStyle(
                      //       fontSize: 14.sp,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                      // FancySeekBar(
                      //   value: state.faceVerificationTries ?? 6,
                      //   max: 9,
                      //   min: 3,
                      //   onChanged: (value) {
                      //     ref
                      //         .read(settingScreenStateProvider.notifier)
                      //         .setFaceTries(value);
                      //   },
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.r),

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                  ),
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 13.r),
                                ),

                                onPressed: () async {
                                  HapticFeedback.heavyImpact();
                                  await Future.delayed(
                                    Duration(milliseconds: 100),
                                  );
                                  showIdentificationDialog(false);
                                },
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "register_face_id".tr(),

                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.r),

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.w),
                                  ),

                                  backgroundColor:
                                      (state.faces != null &&
                                          state.faces?.isNotEmpty == true)
                                      ? Colors.white
                                      : Colors.white.withAlpha(100),
                                  padding: EdgeInsets.symmetric(vertical: 13.r),
                                ),

                                onPressed: () async {
                                  HapticFeedback.heavyImpact();
                                  await Future.delayed(
                                    Duration(milliseconds: 100),
                                  );
                                  print(
                                    "faces=======> size ${state.faces?.length}",
                                  );
                                  if (state.faces != null &&
                                      state.faces?.isNotEmpty == true) {
                                    showIdentificationDialog(true);
                                  }
                                },
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "edit_face_id".tr(),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color:
                                          (state.faces != null &&
                                              state.faces?.isNotEmpty == true)
                                          ? Colors.black
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                            backgroundColor: Colors.white,
                          ),

                          onPressed: showDeleteFaceDialog,
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              "delete_face_id".tr(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      10.verticalSpace,
                      10.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                            backgroundColor: Colors.white,
                          ),

                          onPressed: _uploadArchiveEvent,
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              "upload_archive_event".tr(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      30.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (state.isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black38,
              child: Center(
                child: SpinKitFadingCube(
                  color: MColors().crimsonRed,
                  size: 100.0.r,
                  duration: Duration(milliseconds: 1000),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose focus node to prevent memory leaks
    super.dispose();
  }
}
