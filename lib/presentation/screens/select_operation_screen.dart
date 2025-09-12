import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          .setCurrentPerformAndActionState(widget.employee.id!);
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
    final empPerformAndActionState = ref.watch(
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
      body: Padding(
        padding: EdgeInsets.all(5.r),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _rowButton(
              firstButtonName: "stewarding".tr().toUpperCase(),
              secondButtonName: "unterhalt".tr().toUpperCase(),
              firstButtonOnPressed:
                  empPerformAndActionState
                          .currentEmpPerformState
                          ?.isStewarding ??
                      true
                  ? () {
                      navigateToActionScreen(Perform.STEWARDING);
                    }
                  : null,
              secondButtonOnPressed:
                  empPerformAndActionState
                          .currentEmpPerformState
                          ?.isMaintenance ??
                      true
                  ? () {
                      navigateToActionScreen(Perform.MAINTENANCE);
                    }
                  : null,
              firstButtonColor:
                  empPerformAndActionState
                          .currentEmpPerformState
                          ?.isStewarding ??
                      true
                  ? Colors.black
                  : MColors().darkGrey,
              secondButtonColor:
                  empPerformAndActionState
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
                  empPerformAndActionState
                          .currentEmpPerformState
                          ?.isRoomControl ??
                      true
                  ? () {
                      navigateToActionScreen(Perform.ROOMCONTROL);
                    }
                  : null,
              secondButtonOnPressed:
                  empPerformAndActionState
                          .currentEmpPerformState
                          ?.isRoomCleaning ??
                      true
                  ? () {
                      navigateToActionScreen(Perform.ROOMCLEANING);
                    }
                  : null,
              firstButtonColor:
                  empPerformAndActionState
                          .currentEmpPerformState
                          ?.isRoomControl ??
                      true
                  ? Colors.black
                  : MColors().darkGrey,
              secondButtonColor:
                  empPerformAndActionState
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
                    empPerformAndActionState.currentEmpPerformState?.isBuro ??
                        true
                    ? () {
                        navigateToActionScreen(Perform.BURO);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      empPerformAndActionState.currentEmpPerformState?.isBuro ??
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
    );
  }
}
