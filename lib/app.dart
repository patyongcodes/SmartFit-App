import 'package:flutter/material.dart';

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFit',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const Placeholder(),
    );
  }
}