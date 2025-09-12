import 'package:flutter/material.dart';

import '../presentation/theme/colors.dart';

showSnackBar(String text, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        backgroundColor: MColors().freshGreen,
        content: Text(
          text,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        )),
  );
}
showErrorSnackBar(String text, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        backgroundColor: MColors().crimsonRed,
        content: Text(
          text,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        )),
  );
}
