import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  void _showDeleteAllFacesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete All Faces",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete ALL registered faces? This action cannot be undone.\n\nThis is a debug feature for development only.",
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllFaces();
              },
              child: Text("Delete All", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllFaces() async {
    try {
      final faceRepo = ref.read(faceRepoProvider);

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Text("Deleting all faces..."),
            ],
          ),
        ),
      );

      // Use the efficient bulk delete method
      final deleteResult = await faceRepo.deleteAllFaces();

      Navigator.of(context).pop(); // Close loading dialog

      deleteResult.fold(
        (error) {
          _showErrorDialog("Failed to delete all faces: $error");
        },
        (_) {
          _showSuccessDialog();
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if open
      _showErrorDialog("Unexpected error: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success", style: TextStyle(color: Colors.green)),
        content: Text("All faces have been deleted successfully!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
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
        showErrorSnackBar("Face ID already Registered", context);
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
    ref.read(settingScreenStateProvider.notifier).setFaceIDForAll(value);
  }

  void setFaceIdForRegisterFace(bool value) async {
    ref
        .read(settingScreenStateProvider.notifier)
        .setFaceIDForRegisterFace(value);
  }

  void _showAuthenticationDialog() async {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingScreenStateProvider);

    ref.listen(settingScreenStateProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty) {
        showErrorSnackBar(next.errorMessage, context);
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: IconButton(
              iconSize: 30.w,
              onPressed: () {
                ref.read(settingScreenStateProvider.notifier).syncData();
              },
              icon: Icon(Icons.cloud_download_outlined),
              color: MColors().greenMunsell,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: IconButton(
              iconSize: 30.w,
              onPressed: _showAuthenticationDialog,
              icon: Icon(Icons.key),
              color: MColors().crimsonRed,
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
                          "Face ID Settings",
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          "num_of_retries".tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      FancySeekBar(value: 6, max: 9, min: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              backgroundColor: Colors.white,
                            ),

                            onPressed: () {
                              showIdentificationDialog(false);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                "register_face_id".tr(),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.w),
                              ),

                              backgroundColor:
                                  (state.faces != null &&
                                      state.faces?.isNotEmpty == true)
                                  ? Colors.white
                                  : Colors.white.withAlpha(100),
                            ),

                            onPressed: () {
                              print(
                                "faces=======> size ${state.faces?.length}",
                              );
                              if (state.faces != null &&
                                  state.faces?.isNotEmpty == true) {
                                showIdentificationDialog(true);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                "edit_face_id".tr(),
                                style: TextStyle(
                                  color:
                                      (state.faces != null &&
                                          state.faces?.isNotEmpty == true)
                                      ? Colors.black
                                      : Colors.grey.shade600,
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
                              style: TextStyle(color: Colors.black),
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

                          onPressed: () {},
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              "upload_archive_event".tr(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),

                      10.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      20.verticalSpace,
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Text(
                          "Debug Tools",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                          ),
                          onPressed: () => _showDeleteAllFacesDialog(context),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Text(
                              "Delete All Faces (Debug)",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
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
                child: SpinKitCubeGrid(
                  color: Colors.red,
                  size: 100.0.r,
                  duration: Duration(milliseconds: 800),
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
