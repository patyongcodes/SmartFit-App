import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'main.dart';

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp.router(
          title: 'SmartFit',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeAnimationDuration: const Duration(milliseconds: 450),
          themeAnimationCurve: Curves.easeInOut,
          routerConfig: appRouter,
        );
      },
    );
  }
}