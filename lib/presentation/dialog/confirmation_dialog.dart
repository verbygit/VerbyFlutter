import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmationDialog extends ConsumerWidget {
  const ConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "confirmation_text".tr(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25.sp,
              ),
            ),
            40.verticalSpace,

            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: ()async {
                        HapticFeedback.heavyImpact();
                        await Future.delayed(Duration(milliseconds: 200));
                        Navigator.pop(context, false);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.all(10.r),
                          child: Center(
                            child: Text(
                              "no".tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500
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
                      onTap: () async{
                        HapticFeedback.heavyImpact();
                        await Future.delayed(Duration(milliseconds: 200));
                        Navigator.pop(context, true);
                      },

                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.r),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Center(
                            child: Text(
                              "yes".tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500
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
    );
  }
}
