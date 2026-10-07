import 'package:flutter/material.dart';
import '../../core/widgets/app_drawer.dart';

class TutorialDetailScreen extends StatelessWidget {
  const TutorialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial Detail')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Tutorial Detail')),
    );
  }
}