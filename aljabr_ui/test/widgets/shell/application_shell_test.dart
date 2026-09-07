import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import 'package:aljabr/widgets/shell/application_shell.dart';
import 'package:aljabr/widgets/shell/shell_region_host.dart';
import 'package:aljabr/providers/module_manager_provider.dart';

void main() {
  group('ApplicationShell & ShellRegionHost Widget Tests', () {
    testWidgets('ApplicationShell renders top, main, and status shell regions', (tester) async {
      final runtime = ExtensionRuntime();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            extensionRuntimeProvider.overrideWithValue(runtime),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ApplicationShell(),
            ),
          ),
        ),
      );

      expect(find.byType(ApplicationShell), findsOneWidget);
      expect(find.byType(ShellRegionHost), findsNWidgets(3));
    });
  });
}
