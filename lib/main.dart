import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Global theme notifier accessed across the app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'SmartFit',

          // Connects GoRouter configuration
          routerConfig: appRouter,

          themeMode: currentMode,

          // Using configured AppTheme with Plus Jakarta Sans & App Palette
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,

          // Smooth theme color transition overlay without breaking GoRouter
          builder: (context, child) {
            final currentTheme = Theme.of(context);
            final isDark = currentTheme.brightness == Brightness.dark;

            return AnimatedTheme(
              data: currentTheme,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}