import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tenun/registry/bundle_core.dart';
import 'screens/ide_home_screen.dart';
import 'theme/app_colors.dart';

/// Forces all connections to 127.0.0.1 and localhost to bypass any system
/// HTTP proxy (e.g., Proxyman, Charles, corporate VPN proxies). Without this,
/// Dart's HttpClient picks up http_proxy env vars and routes gRPC to the wrong
/// port (e.g., 52295 or 63778), causing immediate "Connection refused" errors.
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
  // Register core chart bundles for Tenun
  coreChartsBundle.register();
  await Hive.initFlutter();
  await Hive.openBox('aljabr_prefs');
  await Hive.openBox('aljabr_sessions');
  await Hive.openBox('aljabr_chat_history');
  HttpOverrides.global = _NoProxyOverrides();
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
