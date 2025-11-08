import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/presentation/dialog/confirmation_dialog.dart';
import 'package:verby_flutter/presentation/dialog/room_status_selection_dialog.dart';
import 'package:verby_flutter/presentation/screens/depa_and_room/room_item.dart';

import '../../../data/models/local/depa_restant_model.dart';
import '../../../domain/entities/room_status.dart';
import '../../providers/depa_restant_state_provider.dart';
import '../../theme/colors.dart';

class RoomAndDepaScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const RoomAndDepaScreen({super.key, required this.employee});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _RoomAndDepaScreenState();
  }
}

class _RoomAndDepaScreenState extends ConsumerState<RoomAndDepaScreen> {
  @override
  void initState() {
    ref
        .read(depaRestantProvider.notifier)
        .setDepasAndRestant(widget.employee.id.toString());
    super.initState();
  }

  void showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return ConfirmationDialog();
      },
    );

    if (result == true) {
      var depa = ref.read(depaRestantProvider).depa;
      var restant = ref.read(depaRestantProvider).restant;

      var backstackResult = {"depa": depa, "restant": restant};
      Navigator.pop(context, backstackResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final depaRestantState = ref.watch(depaRestantProvider);
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
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Text(
            "rooms".tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5.r),
                            child: Text(
                              "depa".tr(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.all(6.r),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2.5,
                                  ),
                              itemCount: depaRestantState.depa?.length ?? 0,
                              itemBuilder: (context, index) {
                                final depa = depaRestantState.depa?[index];
                                final bgColor =
                                    switch (RoomStatus.getRoomStatus(
                                      depa?.status ?? 0,
                                    )) {
                                      RoomStatus.DEFAULT =>
                                        MColors().mediumDarkGray,
                                      RoomStatus.CLEANED =>
                                        MColors().freshGreen,
                                      RoomStatus.REDCARCD =>
                                        MColors().crimsonRed,
                                      RoomStatus.VOLUNTER =>
                                        MColors().chartreuse,
                                    };
                                return roomItem(depa, bgColor, () async {
                                  HapticFeedback.heavyImpact();
                                  await Future.delayed(
                                    Duration(milliseconds: 150),
                                  );
                                  if (depa != null) {
                                    final result =
                                        await showDialog<DepaRestantModel>(
                                          context: context,
                                          builder: (context) {
                                            return RoomStatusSelectionDialog(
                                              depaRestantModel: depa,
                                            );
                                          },
                                        );
                                    if (result != null) {
                                      ref
                                          .read(depaRestantProvider.notifier)
                                          .updateDepa(result, index);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5.r),

                            child: Text(
                              "restant".tr(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.all(6.r),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // Number of columns
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2.5,
                                  ),
                              itemCount: depaRestantState.restant?.length ?? 0,
                              itemBuilder: (context, index) {
                                final restant =
                                    depaRestantState.restant?[index];
                                final bgColor =
                                    switch (RoomStatus.getRoomStatus(
                                      restant?.status ?? 0,
                                    )) {
                                      RoomStatus.DEFAULT =>
                                        MColors().mediumDarkGray,
                                      RoomStatus.CLEANED =>
                                        MColors().freshGreen,
                                      RoomStatus.REDCARCD =>
                                        MColors().crimsonRed,
                                      RoomStatus.VOLUNTER =>
                                        MColors().chartreuse,
                                    };
                                return roomItem(restant, bgColor, () async {
                                  HapticFeedback.heavyImpact();
                                  await Future.delayed(
                                    Duration(milliseconds: 150),
                                  );
                                  if (restant != null) {
                                    final result =
                                        await showDialog<DepaRestantModel>(
                                          context: context,
                                          builder: (context) {
                                            return RoomStatusSelectionDialog(
                                              depaRestantModel: restant,
                                            );
                                          },
                                        );
                                    if (result != null) {
                                      ref
                                          .read(depaRestantProvider.notifier)
                                          .updateRestant(result, index);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.r,
                      vertical: 20.r,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              ref
                                  .read(depaRestantProvider.notifier)
                                  .getDepasAndRestant(widget.employee.id ?? -1);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.r),

                              child: Container(
                                decoration: BoxDecoration(
                                  color: MColors().chartreuse,
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.r),

                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,

                                    child: Text(
                                      "reset".tr(),
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
                          ),
                        ),
                        20.horizontalSpace,
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              showConfirmationDialog();
                            },

                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.r),

                              child: Container(
                                decoration: BoxDecoration(
                                  color: MColors().freshGreen,
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.r),

                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "submit_button".tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
            ),
            if (depaRestantState.isLoading)
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
