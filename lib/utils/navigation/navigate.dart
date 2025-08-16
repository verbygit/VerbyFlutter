import 'package:flutter/cupertino.dart';

void navigateToScreen(BuildContext context, Widget widget) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

void navigatePushAndRemoveUntil(
    BuildContext context, Widget widget, bool shouldSaveFirst) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from right side
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration:
          const Duration(milliseconds: 300), // Duration of the slide animation
    ),
    (Route<dynamic> route) => shouldSaveFirst ? route.isFirst : false,
  );
}

void navigatePushReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}
