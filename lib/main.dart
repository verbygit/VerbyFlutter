import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/domain/core/connectivity_helper.dart';
import 'package:verby_flutter/presentation/screens/worker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize essential services in parallel
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  ConnectivityHelper().initialize();
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
