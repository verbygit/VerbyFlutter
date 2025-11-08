import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/presentation/screens/volunteer_selection_screen.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';

class RoomStatusSelectionDialog extends StatelessWidget {
  final DepaRestantModel depaRestantModel;

  // final void Function(DepaRestantModel) onStatusChanged;

  const RoomStatusSelectionDialog({
    super.key,
    required this.depaRestantModel,
    // required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          20.verticalSpace,
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Text(
              "please_chose".tr(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          30.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      await Future.delayed(Duration(milliseconds: 100));

                      depaRestantModel.status = 2;
                      Navigator.pop(context, depaRestantModel);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.r),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MColors().crimsonRed,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.r,horizontal: 10.r),
                        child: Center(
                          child: Text(
                            "red_card".tr().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      await Future.delayed(Duration(milliseconds: 100));
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VolunteerSelectionScreen(),
                        ),
                      );

                      if (result != null) {
                        depaRestantModel.volunteer = result;
                        depaRestantModel.status = 3;
                        Navigator.pop(context, depaRestantModel);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.r),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MColors().chartreuse,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.r,horizontal: 10.r),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "had_volunteer".tr().toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
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
          Padding(
            padding: EdgeInsets.symmetric( horizontal: 75.r),
            child: InkWell(
              onTap: () async{
                HapticFeedback.heavyImpact();
                await Future.delayed(Duration(milliseconds: 100));

                depaRestantModel.status = 0;
                Navigator.pop(context, depaRestantModel);
              },

              child: Padding(
                padding: EdgeInsets.symmetric( vertical: 20.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: MColors().mediumDarkGray,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15.r,horizontal: 10.r),
                  child: Center(
                    child: Text(
                      "did_not_clean".tr().toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          30.verticalSpace,
        ],
      ),
    );
  }
}
