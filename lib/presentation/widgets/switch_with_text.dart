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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        5.horizontalSpace,
        Theme(
          data: Theme.of(context).copyWith(
            switchTheme: SwitchThemeData(
              trackOutlineColor: MaterialStateProperty.all(
                Colors.transparent,
              ),
            ),
          ),
          child: Transform.scale(
            scale: 0.7.r,
            child: Switch(
              value: isChecked,
              onChanged: onChanged,
              activeColor: MColors().greenMunsell,
            ),
          ),
        ),
      ],
    );
  }
}
