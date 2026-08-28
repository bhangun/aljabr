import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tenun/registry/bundle_core.dart';
import 'screens/ide_home_screen.dart';
import 'theme/app_colors.dart';
import 'providers/module_manager_provider.dart';
import 'core/modules/core_navigation_module.dart';
import 'core/modules/core_settings_module.dart';
import 'core/modules/backend_monitor_module.dart';
import 'core/modules/chat_module.dart';
import 'core/modules/editor_module.dart';

class _NoProxyOverrides extends HttpOverrides {
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (url.host == '127.0.0.1' ||
        url.host == 'localhost' ||
        url.host == '::1') {
      return 'DIRECT';
    }
    return super.findProxyFromEnvironment(url, environment);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  coreChartsBundle.register();
  await Hive.initFlutter();
  await Hive.openBox('aljabr_prefs');
  await Hive.openBox('aljabr_sessions');
  await Hive.openBox('aljabr_chat_history');
  HttpOverrides.global = _NoProxyOverrides();
  
  final container = ProviderContainer();
  final manager = container.read(moduleManagerProvider);
  
  // Register modules sequentially
  await manager.activate(CoreNavigationModule());
  await manager.activate(CoreSettingsModule());
  await manager.activate(BackendMonitorModule());
  await manager.activate(ChatModule());
  await manager.activate(EditorModule());

  runApp(ProviderScope(
    parent: container,
    child: const WayangIdeApp(),
  ));
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
