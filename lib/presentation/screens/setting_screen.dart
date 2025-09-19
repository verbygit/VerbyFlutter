import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/presentation/dialog/indentification_dialog.dart';
import 'package:verby_flutter/presentation/dialog/password_dialog.dart';
import 'package:verby_flutter/presentation/screens/face_registration_screen.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:verby_flutter/presentation/widgets/switch_with_text.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';
import 'package:verby_flutter/presentation/providers/reposiory/face_repo_provider.dart';

import '../dialog/authentication_dialog.dart';
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

  void showIdentificationDialog() async {
    final buildContext = context;
    final employee = await showDialog<Employee>(
      context: context,
      builder: (context) => IdentificationDialog(),
    );

    if (employee != null) {
      showPinDialog(buildContext, employee, (isCorrectPin) {
        if (isCorrectPin) {
          safeNavigateToScreen(
            buildContext,
            FaceRegistrationScreen(employee: employee),
          );
        }
      });
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
      barrierDismissible: false,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MColors().darkGrey,
        centerTitle: true,
        title: Text(
          "setting".tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(4.r),
            child: IconButton(
              iconSize: 30.w,
              onPressed: () {},
              icon: Icon(Icons.cloud_download_outlined),
              color: MColors().greenMunsell,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(4.r),
            child: IconButton(
              iconSize: 30.w,
              onPressed: _showAuthenticationDialog,
              icon: Icon(Icons.key),
              color: MColors().crimsonRed,
            ),
          ),
        ],
        actionsPadding: EdgeInsets.all(10.r),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: Material(
              color: MColors().veryLightGray,
              elevation: 10,
              borderRadius: BorderRadius.circular(15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.verticalSpace,
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Text(
                      "Face ID Settings",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
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
                        ),

                        onPressed: showIdentificationDialog,
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Text(
                            "register_face_id".tr(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.w),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Text(
                          "edit_face_id".tr(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  // Debug section
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
    );
  }

  @override
  void dispose() {
    // Dispose focus node to prevent memory leaks
    super.dispose();
  }
}
