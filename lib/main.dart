import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/domain/core/connectivity_helper.dart';
import 'package:verby_flutter/presentation/screens/checklist/room_list_screen.dart';
import 'package:verby_flutter/presentation/screens/worker_screen.dart';
import 'package:verby_flutter/data/service/lock_task_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize essential services in parallel
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  ConnectivityHelper().initialize();
  
  // Initialize lock task service
  await LockTaskService().initialize();

  // Capture Flutter errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Capture platform errors (non-Flutter)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Enable Crashlytics in non-debug builds
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    true,
  );
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: [Locale('en'), Locale('de')],
        path: 'assets/langs',
        fallbackLocale: Locale('en', ''),
        child: Verby(),
      ),
    ),
  );
}

class Verby extends ConsumerWidget {
  const Verby({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          EasyLocalization.of(context)!.delegate, // Add this line
        ],
        home: SafeArea(child: Scaffold(body: WorkerScreen())),
      ),
    );
  }
}
