import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/colors.dart';

class TextSwitch extends StatelessWidget {
  final text;
  final isChecked;
  final void Function(bool)? onChanged;

  const TextSwitch({super.key, this.text, this.isChecked, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),),
        Theme(
          data: Theme.of(context).copyWith(
            switchTheme: SwitchThemeData(
              trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
          child: Switch(
            value: isChecked,
            onChanged: onChanged,
            activeColor: MColors().greenMunsell,
          ),
        ),
      ],
    );
  }
}
