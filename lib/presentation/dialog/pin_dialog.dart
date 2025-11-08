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
      return _PinDialogWidget(
        employee: employee,
        onPinSuccess: onPinSuccess,
      );
    },
  );
}

class _PinDialogWidget extends StatefulWidget {
  final Employee employee;
  final void Function(bool) onPinSuccess;

  const _PinDialogWidget({
    required this.employee,
    required this.onPinSuccess,
  });

  @override
  State<_PinDialogWidget> createState() => _PinDialogWidgetState();
}

class _PinDialogWidgetState extends State<_PinDialogWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Request focus after the dialog is built to open keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              widget.employee.fullname ?? "",
              style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold),
            ),
            40.verticalSpace,
            SizedBox(
              width: 250.w,
              child: PinCodeTextField(
                appContext: context,
                focusNode: _focusNode,
                onCompleted: (text) {
                  // Unfocus the FocusNode before closing dialog
                  _focusNode.unfocus();
                  if (text == widget.employee.pin) {
                    Navigator.pop(context);
                    widget.onPinSuccess(true);
                  } else {
                    Navigator.pop(context);
                    widget.onPinSuccess(false);
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
  }
}
