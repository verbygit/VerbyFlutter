import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/core/connectivity_helper.dart';
import 'package:verby_flutter/domain/entities/perform.dart';
import 'package:verby_flutter/domain/entities/action.dart';
import 'package:verby_flutter/presentation/screens/depa_and_room/rooms_and_depa_screen.dart';
import 'package:verby_flutter/utils/helper_functions.dart';
import '../../data/models/local/depa_restant_model.dart';
import '../providers/emp_perform_action_state_provider.dart';
import '../theme/colors.dart';
import 'loader_screen.dart';

class ActionScreen extends ConsumerStatefulWidget {
  final Perform perform;
  final Employee employee;

  const ActionScreen({
    super.key,
    required this.perform,
    required this.employee,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ActionScreen();
  }
}

class _ActionScreen extends ConsumerState<ActionScreen> {
  Widget _rowButtonWithIcon({
    String firstButtonName = "",
    String secondButtonName = "",
    IconData firstButtonIcon = Icons.play_arrow_outlined,
    IconData secondButtonIcon = Icons.play_arrow_outlined,
    void Function()? firstButtonOnPressed,
    void Function()? secondButtonOnPressed,
    Color? firstButtonColor,
    Color? secondButtonColor,
    Color? firstIconColor,
    Color? secondIconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Icon(firstButtonIcon, size: 70.w, color: firstIconColor),

            SizedBox(
              width: 170.w,
              child: ElevatedButton(
                onPressed: firstButtonOnPressed,

                style: ElevatedButton.styleFrom(
                  backgroundColor: firstButtonColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.r),
                  child: Text(
                    firstButtonName,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                ),
              ),
            ),
          ],
        ),

        Column(
          children: [
            Icon(secondButtonIcon, size: 70.w, color: secondIconColor),

            SizedBox(
              width: 170.w,
              child: ElevatedButton(
                onPressed: secondButtonOnPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondButtonColor,
                ),
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
        ),
      ],
    );
  }

  void _createRecord(Action action) async {
    if (action == Action.CHECKOUT &&
        (widget.perform == Perform.MAINTENANCE ||
            widget.perform == Perform.ROOMCLEANING ||
            widget.perform == Perform.ROOMCONTROL)) {
      final result =
          await Navigator.push<Map<String, List<DepaRestantModel?>?>>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RoomAndDepaScreen(employee: widget.employee),
            ),
          );
      if (result != null) {
        callCreateRecordEndpoint(action, result?["depa"], result?["restant"]);
      }

      return;
    }

    callCreateRecordEndpoint(action, null, null);
  }

  void callCreateRecordEndpoint(
    Action action,
    List<DepaRestantModel?>? depa,
    List<DepaRestantModel?>? restant,
  ) async {
    final result = await ref
        .read(empPerformAndActionStateProvider.notifier)
        .createRecord(widget.employee, widget.perform, action, depa, restant);
    if (result) {
      Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(empPerformAndActionStateProvider);

    ref.listen(empPerformAndActionStateProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage) {
        showErrorSnackBar(next.errorMessage, context);
        ref.read(empPerformAndActionStateProvider.notifier).setErrorMessage("");
      }

      if (previous?.message != next.message && next.message.isNotEmpty) {
        showSnackBar(next.message, context);
        ref
            .read(empPerformAndActionStateProvider.notifier)
            .setSuccessMessage("");
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
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(5.r),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rowButtonWithIcon(
                  firstButtonName: "checkin".tr().toUpperCase(),
                  secondButtonName: "check-out".tr().toUpperCase(),
                  firstButtonIcon: Icons.play_arrow_outlined,
                  secondButtonIcon: Icons.stop_outlined,
                  firstButtonOnPressed:
                      state.currentEmpActionState?.checkedIn ?? true
                      ? () {
                          _createRecord(Action.CHECKIN);
                        }
                      : null,
                  secondButtonOnPressed:
                      state.currentEmpActionState?.checkedOut ?? true
                      ? () {
                          _createRecord(Action.CHECKOUT);
                        }
                      : null,
                  firstButtonColor:
                      state.currentEmpActionState?.checkedIn ?? true
                      ? Colors.black
                      : MColors().darkGrey,
                  secondButtonColor:
                      state.currentEmpActionState?.checkedOut ?? true
                      ? Colors.black
                      : MColors().darkGrey,
                  firstIconColor: state.currentEmpActionState?.checkedIn ?? true
                      ? MColors().freshGreen
                      : MColors().veryLightGray2,
                  secondIconColor:
                      state.currentEmpActionState?.checkedOut ?? true
                      ? MColors().crimsonRed
                      : MColors().veryLightGray2,
                ),
                40.verticalSpace,
                _rowButtonWithIcon(
                  firstButtonName: "pause-in".tr().toUpperCase(),
                  secondButtonName: "pause-out".tr().toUpperCase(),
                  firstButtonIcon: Icons.pause,
                  secondButtonIcon: Icons.refresh,
                  firstButtonOnPressed:
                      state.currentEmpActionState?.pausedIn ?? true
                      ? () {
                          _createRecord(Action.PAUSEIN);
                        }
                      : null,
                  secondButtonOnPressed:
                      state.currentEmpActionState?.pausedOut ?? true
                      ? () {
                          _createRecord(Action.PAUSEOUT);
                        }
                      : null,
                  firstButtonColor:
                      state.currentEmpActionState?.pausedIn ?? true
                      ? Colors.black
                      : MColors().darkGrey,
                  secondButtonColor:
                      state.currentEmpActionState?.pausedOut ?? true
                      ? Colors.black
                      : MColors().darkGrey,
                  firstIconColor: state.currentEmpActionState?.pausedIn ?? true
                      ? MColors().amber
                      : MColors().veryLightGray2,
                  secondIconColor:
                      state.currentEmpActionState?.pausedOut ?? true
                      ? MColors().skyBlue
                      : MColors().veryLightGray2,
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
                child: Lottie.asset(
                  'assets/animation/loading_animation.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
