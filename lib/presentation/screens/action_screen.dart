import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/core/connectivity_helper.dart';
import 'package:verby_flutter/domain/entities/perform.dart';
import 'package:verby_flutter/domain/entities/action.dart';
import 'package:verby_flutter/presentation/screens/depa_and_room/rooms_and_depa_screen.dart';
import 'package:verby_flutter/utils/helper_functions.dart';
import 'package:verby_flutter/data/service/sound_service.dart';
import '../../data/models/local/depa_restant_model.dart';
import '../providers/emp_perform_action_state_provider.dart';
import '../theme/colors.dart';
import 'loader_screen.dart';

class ActionScreen extends ConsumerStatefulWidget {
  final Perform perform;
  final Employee employee;
  final bool isFaceVerification;

  const ActionScreen({
    super.key,
    required this.perform,
    required this.employee,
    required this.isFaceVerification,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ActionScreen();
  }
}

class _ActionScreen extends ConsumerState<ActionScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((ctx) {});
  }

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(firstButtonIcon, size: 70.w, color: firstIconColor),

                InkWell(
                  onTap: firstButtonOnPressed,

                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: firstButtonColor,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20.r),
                      child: Center(
                        child: Text(
                          firstButtonName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
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
          10.horizontalSpace,
          Expanded(
            child: Column(
              children: [
                Icon(secondButtonIcon, size: 70.w, color: secondIconColor),

                InkWell(
                  onTap: secondButtonOnPressed,

                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.r),

                    child: Container(
                      decoration: BoxDecoration(
                        color: secondButtonColor,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20.r),
                      child: Center(
                        child: Text(
                          secondButtonName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
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
        ],
      ),
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
        .createRecord(
          widget.employee,
          widget.perform,
          action,
          widget.isFaceVerification ? 2 : 1,
          depa,
          restant,
        );
    if (result) {
      // Play thank you sound based on current language
      SoundService.playThankYouSound(context);
      Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(empPerformAndActionStateProvider);

    ref.listen(empPerformAndActionStateProvider, (previous, next) {
      if (mounted) {
        if (previous?.errorMessage != next.errorMessage) {
          showErrorSnackBar(next.errorMessage, context);
          ref
              .read(empPerformAndActionStateProvider.notifier)
              .setErrorMessage("");
        }

        if (previous?.message != next.message && next.message.isNotEmpty) {
          print("message on record create in listener ====> ${next.message}");

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
            "chose_action".tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
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
                        ? ()async {
                      HapticFeedback.heavyImpact();
                      await Future.delayed(Duration(milliseconds: 100));
                      _createRecord(Action.CHECKIN);
                          }
                        : null,
                    secondButtonOnPressed:
                        state.currentEmpActionState?.checkedOut ?? true
                        ? () async{
                          HapticFeedback.heavyImpact();
                          await Future.delayed(Duration(milliseconds: 100));
                            _createRecord(Action.CHECKOUT);
                          }
                        : null,
                    firstButtonColor:
                        state.currentEmpActionState?.checkedIn ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                    secondButtonColor:
                        state.currentEmpActionState?.checkedOut ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                    firstIconColor:
                        state.currentEmpActionState?.checkedIn ?? true
                        ? MColors().freshGreen
                        : MColors().veryLightGray2,
                    secondIconColor:
                        state.currentEmpActionState?.checkedOut ?? true
                        ? MColors().crimsonRed
                        : MColors().veryLightGray2,
                  ),
                  20.verticalSpace,
                  _rowButtonWithIcon(
                    firstButtonName: "pause-in".tr().toUpperCase(),
                    secondButtonName: "pause-out".tr().toUpperCase(),
                    firstButtonIcon: Icons.pause,
                    secondButtonIcon: Icons.refresh,
                    firstButtonOnPressed:
                        state.currentEmpActionState?.pausedIn ?? true
                        ? () async{
                          HapticFeedback.heavyImpact();
                          await Future.delayed(Duration(milliseconds: 100));
                            _createRecord(Action.PAUSEIN);
                          }
                        : null,
                    secondButtonOnPressed:
                        state.currentEmpActionState?.pausedOut ?? true
                        ? () async{
                          HapticFeedback.heavyImpact();
                          await Future.delayed(Duration(milliseconds: 100));
                            _createRecord(Action.PAUSEOUT);
                          }
                        : null,
                    firstButtonColor:
                        state.currentEmpActionState?.pausedIn ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                    secondButtonColor:
                        state.currentEmpActionState?.pausedOut ?? true
                        ? Colors.black
                        : MColors().darkGrey50Opacity,
                    firstIconColor:
                        state.currentEmpActionState?.pausedIn ?? true
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
