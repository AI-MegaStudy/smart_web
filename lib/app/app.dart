import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'router.dart';
import 'theme.dart';

class HarvestSlotApp extends StatelessWidget {
  const HarvestSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Harvest Slot',
          debugShowCheckedModeBanner: false,
          theme: buildHarvestTheme(),
          navigatorKey: AppRoutes.navigatorKey,
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
