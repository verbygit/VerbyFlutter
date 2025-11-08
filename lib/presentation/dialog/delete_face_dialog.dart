import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/presentation/dialog/pin_dialog.dart';
import 'package:verby_flutter/presentation/widgets/error_box.dart';
import 'package:verby_flutter/utils/helper_functions.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';
import '../providers/delete_dialog_provider.dart';
import '../providers/indentification_provider.dart';
import '../screens/loader_screen.dart';

class DeleteFaceDialog extends ConsumerStatefulWidget {
  const DeleteFaceDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DeleteFaceDialogState();
  }
}

class _DeleteFaceDialogState extends ConsumerState<DeleteFaceDialog> {
  final _idController = TextEditingController();
  FocusNode? _focusNode;

  Future<void> _checkEmployeeID() async {
    HapticFeedback.heavyImpact();
    if (_idController.text.isEmpty) {
      ref
          .read(identificationDialogProvider.notifier)
          .setError("enter_your_id".tr());
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoaderScreen(),
        opaque: false,
        barrierDismissible: false,
      ),
    );
    try {
      final employees = await ref
          .read(deleteFaceDialogProvider.notifier)
          .getEmployees();
      if (employees.isEmpty) {
        ref
            .read(identificationDialogProvider.notifier)
            .setError("resync_server".tr());
        safeNavigateBack(context);
        return;
      }
      Employee? employee = employees.firstWhere(
        (element) => element.id == int.parse(_idController.text),
        orElse: () => Employee(id: -1, name: "Unknown"), // fallback
      );

      if (employee.id == int.parse(_idController.text)) {
        ref.read(deleteFaceDialogProvider.notifier).clearError();
        safeNavigateBack(context);
        Navigator.pop(context, employee);
      } else {
        ref.read(deleteFaceDialogProvider.notifier).setError("not_valid".tr());
        safeNavigateBack(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identificationState = ref.watch(identificationDialogProvider);
    ref.listen(identificationDialogProvider, (previous, next) {
      if (next.error?.isNotEmpty == true) {
        showErrorSnackBar(next.error!, context);
      }
    });
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 15,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "enter_your_id".tr(),
              style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
            ),
            40.verticalSpace,

            if (identificationState.error?.isNotEmpty == true)
              ErrorBox(identificationState.error ?? ""),
            20.verticalSpace,

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.black, width: 2.w),
              ),

              child: TextField(
                focusNode: _focusNode,
                controller: _idController,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  ref.read(identificationDialogProvider.notifier).clearError();
                },
                maxLength: 10,
                decoration: InputDecoration(
                  // hintText: "enter_your_id".tr(),
                  border: InputBorder.none,
                  counterText: "",
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),

            60.verticalSpace,

            ElevatedButton(
              onPressed: _checkEmployeeID,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: Text(
                  "submit_button".tr(),
                  style: TextStyle(color: Colors.white, fontSize: 20.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
