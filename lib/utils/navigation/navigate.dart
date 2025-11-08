import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

/// Safe navigation method that checks if navigator is available
void safeNavigateBack(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

/// Safe navigation with delay to prevent navigator lock issues
void safeNavigateBackWithDelay(BuildContext context, {Duration delay = const Duration(milliseconds: 100)}) {
  Future.delayed(delay, () {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  });
}

/// Safe navigation to screen with proper error handling
void  safeNavigateToScreen(BuildContext context, Widget widget) {
  if (context.mounted) {
    try {
      navigateToScreen(context, widget);
    } catch (e) {
      print('Navigation error: $e');
      // Fallback to simple push
      Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
    }
  }
}
