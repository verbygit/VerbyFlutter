import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/entities/perform.dart';
import 'package:verby_flutter/presentation/providers/emp_perform_action_state_provider.dart';
import 'package:verby_flutter/presentation/screens/action_screen.dart';
import 'package:verby_flutter/presentation/screens/checklist/room_list_screen.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';

import '../../utils/helper_functions.dart';
import '../theme/colors.dart';

class SelectOperationScreen extends ConsumerStatefulWidget {
  final Employee employee;
  final bool? isFromFaceVerification;

  const SelectOperationScreen({
    super.key,
    required this.employee,
    this.isFromFaceVerification,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SelectOperationScreenState();
  }
}

class _SelectOperationScreenState extends ConsumerState<SelectOperationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(empPerformAndActionStateProvider.notifier)
          .listenToInternetStatus();

      ref
          .read(empPerformAndActionStateProvider.notifier)
          .syncSingleEmpData(widget.employee);
    });
  }

  Widget _rowButton({
    String firstButtonName = "",
    String secondButtonName = "",
    void Function()? firstButtonOnPressed,
    void Function()? secondButtonOnPressed,
    Color? firstButtonColor,
    Color? secondButtonColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: firstButtonOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: firstButtonColor,
              overlayColor: Colors.yellow.withValues(alpha: 0.1),
              splashFactory: InkRipple.splashFactory,
              padding: EdgeInsets.symmetric(vertical: 20.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),

            child: Text(
              firstButtonName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: ElevatedButton(
            onPressed: secondButtonOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondButtonColor,
              overlayColor: Colors.white,

              // splashFactory: InkSparkle.splashFactory,
              padding: EdgeInsets.symmetric(vertical: 20.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Center(
              child: Text(
                secondButtonName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void navigateToActionScreen(Perform perform) {
    safeNavigateToScreen(
      context,
      ActionScreen(
        perform: perform,
        employee: widget.employee,
        isFaceVerification: widget.isFromFaceVerification ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(empPerformAndActionStateProvider);
    ref.listen(empPerformAndActionStateProvider, (previous, next) {
      if (mounted) {
        if (previous?.errorMessage != next.errorMessage &&
            next.errorMessage.isNotEmpty) {
          ref
              .read(empPerformAndActionStateProvider.notifier)
              .setErrorMessage("");
          showErrorSnackBar(next.errorMessage, context);
        }
        if (previous?.message != next.message && next.message.isNotEmpty) {
          showSnackBar(next.message, context);

          ref
              .read(empPerformAndActionStateProvider.notifier)
              .setSuccessMessage("");
        }
      }
    });

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Detect left-to-right swipe (iOS back gesture)
        if (Platform.isIOS) {
          if (details.delta.dx > 5) {
            // Adjust sensitivity as needed
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: MColors().darkGrey,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Text(
            "chose_operation".tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            safeNavigateToScreen(context, RoomListScreen());
          },
          label: Text('Quality Check',style: TextStyle(
            color: Colors.white
          ),), // Text label
          icon: Icon(Icons.add,color: Colors.white,), // Optional icon
          backgroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(5.r),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _rowButton(
                    firstButtonName: "stewarding".tr().toUpperCase(),
                    secondButtonName: "unterhalt".tr().toUpperCase(),
                    firstButtonOnPressed:
                        state.currentEmpPerformState?.isStewarding ?? true
                        ? () async {
                            HapticFeedback.heavyImpact();
                            await Future.delayed(Duration(milliseconds: 200));
                            navigateToActionScreen(Perform.STEWARDING);
                          }
                        : null,
                    secondButtonOnPressed:
                        state.currentEmpPerformState?.isMaintenance ?? true
                        ? () async {
                            HapticFeedback.heavyImpact();
                            await Future.delayed(Duration(milliseconds: 200));
                            navigateToActionScreen(Perform.MAINTENANCE);
                          }
                        : null,
                    firstButtonColor:
                        state.currentEmpPerformState?.isStewarding ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                    secondButtonColor:
                        state.currentEmpPerformState?.isMaintenance ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                  ),
                  20.verticalSpace,
                  _rowButton(
                    firstButtonName: "gouvernante".tr().toUpperCase(),
                    secondButtonName: "raumpflegerin".tr().toUpperCase(),
                    firstButtonOnPressed:
                        state.currentEmpPerformState?.isRoomControl ?? true
                        ? () async {
                            HapticFeedback.heavyImpact();
                            await Future.delayed(Duration(milliseconds: 200));
                            navigateToActionScreen(Perform.ROOMCONTROL);
                          }
                        : null,
                    secondButtonOnPressed:
                        state.currentEmpPerformState?.isRoomCleaning ?? true
                        ? () async {
                            HapticFeedback.heavyImpact();
                            await Future.delayed(Duration(milliseconds: 200));
                            navigateToActionScreen(Perform.ROOMCLEANING);
                          }
                        : null,
                    firstButtonColor:
                        state.currentEmpPerformState?.isRoomControl ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                    secondButtonColor:
                        state.currentEmpPerformState?.isRoomCleaning ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                  ),
                  40.verticalSpace,

                  InkWell(
                    onTap: state.currentEmpPerformState?.isBuro ?? true
                        ? () async {
                            HapticFeedback.heavyImpact();
                            await Future.delayed(Duration(milliseconds: 200));
                            navigateToActionScreen(Perform.BURO);
                          }
                        : null,

                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: state.currentEmpPerformState?.isBuro ?? true
                              ? Colors.black
                              : MColors().darkGrey50Opacity,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.r),
                        child: Center(
                          child: Text(
                            "buro".tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}
