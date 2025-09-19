import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/presentation/providers/login_provider.dart';
import 'package:verby_flutter/presentation/screens/setting_screen.dart';
import 'package:verby_flutter/presentation/screens/loader_screen.dart';
import 'package:verby_flutter/presentation/widgets/error_box.dart';
import '../../utils/navigation/navigate.dart';

class PasswordDialog extends ConsumerStatefulWidget {
  const PasswordDialog({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PasswordDialogState();
  }
}

class _PasswordDialogState extends ConsumerState<PasswordDialog> {
  final _passwordController = TextEditingController();
  bool _hasNavigated = false;
  FocusNode? _focusNode;

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
    _passwordController.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Handle navigation only once when password is correct
    if (loginState.isPasswordCorrect && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(loginProvider.notifier).clearError();
          Navigator.pop(context,true); // Close the dialog first
        }
      });
    }

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
              "enter_password".tr(),
              style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
            ),
            60.verticalSpace,
            if (loginState.error?.isNotEmpty == true)
              ErrorBox(loginState.error ?? ""),

            30.verticalSpace,

            TextField(
              focusNode: _focusNode,
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(fontSize: 16.sp, color: Colors.black),
              textAlign: TextAlign.center,
              decoration: InputDecoration(hintText: "password".tr()),
            ),

            60.verticalSpace,

            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoaderScreen(),
                    opaque: false,
                    barrierDismissible: false,
                  ),
                );
                await ref
                    .read(loginProvider.notifier)
                    .checkPassword(_passwordController.text);
                Navigator.pop(context);
              },
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
