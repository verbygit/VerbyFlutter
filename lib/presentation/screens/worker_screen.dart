import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/presentation/theme/colors.dart';

class WorkerScreen extends ConsumerStatefulWidget {
  const WorkerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _WorkerScreen();
  }
}

class _WorkerScreen extends ConsumerState<WorkerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            AppBar(
              backgroundColor: MColors().darkGrey,
              centerTitle: true,
              leading: Center(
                child: Text(
                  "time",
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                ),
              ),
              actions: [
                Center(
                  child: SizedBox(
                    width: 85.w,
                    height: 85.h,
                    child: Image.asset('assets/images/ic_red_indicator.png'),
                  ),
                ),
              ],
              actionsPadding: EdgeInsets.all(10.r),
            ),
            Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                50.verticalSpace,
                Text(
                  "enter_your_id".tr(),
                  style: TextStyle(
                    fontSize: 60.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,

                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),]
        ),
      ),
    );
  }
}
