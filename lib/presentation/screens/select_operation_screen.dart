import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/entities/perform.dart';
import 'package:verby_flutter/presentation/providers/emp_perform_action_state_provider.dart';
import 'package:verby_flutter/presentation/screens/action_screen.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';

import '../../utils/helper_functions.dart';
import '../theme/colors.dart';

class SelectOperationScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const SelectOperationScreen({super.key, required this.employee});

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
          .syncData(widget.employee);
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
        SizedBox(
          width: 170.w,
          child: ElevatedButton(
            onPressed: firstButtonOnPressed,

            style: ElevatedButton.styleFrom(backgroundColor: firstButtonColor),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.r),
              child: Text(
                firstButtonName,
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 170.w,
          child: ElevatedButton(
            onPressed: secondButtonOnPressed,
            style: ElevatedButton.styleFrom(backgroundColor: secondButtonColor),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.r),
              child: Text(
                secondButtonName,
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
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
      ActionScreen(perform: perform, employee: widget.employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      empPerformAndActionStateProvider,
    );
    ref.listen(empPerformAndActionStateProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage.isNotEmpty) {
        showSnackBar(next.errorMessage, context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MColors().darkGrey,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "chose_operation".tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25.sp,
            ),
          ),
        ),
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
                  state
                      .currentEmpPerformState
                      ?.isStewarding ??
                      true
                      ? () {
                    navigateToActionScreen(Perform.STEWARDING);
                  }
                      : null,
                  secondButtonOnPressed:
                  state
                      .currentEmpPerformState
                      ?.isMaintenance ??
                      true
                      ? () {
                    navigateToActionScreen(Perform.MAINTENANCE);
                  }
                      : null,
                  firstButtonColor:
                  state
                      .currentEmpPerformState
                      ?.isStewarding ??
                      true
                      ? Colors.black
                      : MColors().darkGrey,
                  secondButtonColor:
                  state
                      .currentEmpPerformState
                      ?.isMaintenance ??
                      true
                      ? Colors.black
                      : MColors().darkGrey,
                ),
                40.verticalSpace,
                _rowButton(
                  firstButtonName: "gouvernante".tr().toUpperCase(),
                  secondButtonName: "raumpflegerin".tr().toUpperCase(),
                  firstButtonOnPressed:
                  state
                      .currentEmpPerformState
                      ?.isRoomControl ??
                      true
                      ? () {
                    navigateToActionScreen(Perform.ROOMCONTROL);
                  }
                      : null,
                  secondButtonOnPressed:
                  state
                      .currentEmpPerformState
                      ?.isRoomCleaning ??
                      true
                      ? () {
                    navigateToActionScreen(Perform.ROOMCLEANING);
                  }
                      : null,
                  firstButtonColor:
                  state
                      .currentEmpPerformState
                      ?.isRoomControl ??
                      true
                      ? Colors.black
                      : MColors().darkGrey,
                  secondButtonColor:
                  state
                      .currentEmpPerformState
                      ?.isRoomCleaning ??
                      true
                      ? Colors.black
                      : MColors().darkGrey,
                ),
                40.verticalSpace,

                SizedBox(
                  width: 170.w,
                  child: ElevatedButton(
                    onPressed:
                    state.currentEmpPerformState?.isBuro ??
                        true
                        ? () {
                      navigateToActionScreen(Perform.BURO);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      state.currentEmpPerformState?.isBuro ??
                          true
                          ? Colors.black
                          : MColors().darkGrey,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.r),
                      child: Text(
                        "buro".tr(),
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
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
                child: SpinKitCubeGrid(
                  color: Colors.red,
                  size: 100.0.r,
                  duration: Duration(milliseconds: 800),
                )
              ),
            ),
        ],
      ),
    );
  }
}
