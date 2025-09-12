import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';

void showPinDialog(
  BuildContext context,
  Employee employee,
  void Function(bool) onPinSuccess,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (buildContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 15,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "enter_pin".tr(),
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
              ),
              8.verticalSpace,
              Text(
                employee.fullname ?? "",
                style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold),
              ),
              40.verticalSpace,
              SizedBox(
                width: 250.w,
                child: PinCodeTextField(
                  appContext: context,
                  onCompleted: (text) {
                    // Unfocus the FocusNode before closing dialog
                    if (text == employee.pin) {
                      Navigator.pop(context);
                      onPinSuccess(true);
                    } else {
                      Navigator.pop(context);
                      onPinSuccess(false);
                    }
                  },
                  length: 4,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50.h,
                    fieldWidth: 50.w,
                    borderWidth: 1,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black,
                    selectedColor: Colors.black,
                    activeFillColor: Colors.white,
                  ),
                  boxShadows: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
