import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/ide_home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  // ProviderScope is all Riverpod needs at the root — no generated
  // provider container, no build_runner step.
  runApp(const ProviderScope(child: WayangIdeApp()));
}

class WayangIdeApp extends StatelessWidget {
  const WayangIdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aljabr IDE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const IdeHomeScreen(),
    );
  }
}
