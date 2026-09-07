import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr/providers/module_manager_provider.dart';
import 'package:aljabr/widgets/workbench/modes/workspace_mode_segmented_switch.dart';
import 'package:aljabr/widgets/workbench/modes/workspace_mode_status_item.dart';
import 'package:aljabr/widgets/workbench/modes/workspace_view_host.dart';
import 'package:aljabr/widgets/workbench/modes/vibe_coding_workspace_view.dart';
import 'package:aljabr/widgets/workbench/modes/ide_workspace_view.dart';

void main() {
  group('Workspace Mode Switcher and View Host Widget Tests', () {
    late ExtensionRuntime runtime;

    setUp(() {
      runtime = ExtensionRuntime();
      runtime.views.register(
        ViewContribution(
          id: 'chat.view',
          ownerId: 'test',
          title: 'Chat',
          preferredPlacement: ViewPlacement.main,
          builder: (_) => const Text('Chat Stream Content'),
        ),
      );
    });

    testWidgets('WorkspaceModeSegmentedSwitch displays modes and toggles between Vibe and IDE', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            extensionRuntimeProvider.overrideWithValue(runtime),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WorkspaceModeSegmentedSwitch(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Vibe'), findsOneWidget);
      expect(find.text('IDE'), findsOneWidget);

      // Default is IDE mode
      expect(runtime.workspaceModeController.currentModeId, CoreWorkspaceModes.ide);

      // Tap Vibe mode
      await tester.tap(find.text('Vibe'));
      await tester.pumpAndSettle();

      expect(runtime.workspaceModeController.currentModeId, CoreWorkspaceModes.vibe);

      // Tap IDE mode
      await tester.tap(find.text('IDE'));
      await tester.pumpAndSettle();

      expect(runtime.workspaceModeController.currentModeId, CoreWorkspaceModes.ide);
    });

    testWidgets('WorkspaceModeStatusItem displays current mode and opens dialog on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            extensionRuntimeProvider.overrideWithValue(runtime),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WorkspaceModeStatusItem(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('IDE Workspace'), findsOneWidget);

      // Tap to open selection dialog
      await tester.tap(find.text('IDE Workspace'));
      await tester.pumpAndSettle();

      expect(find.text('Switch Workspace Mode'), findsOneWidget);
      expect(find.text('Vibe Coding'), findsOneWidget);
      expect(find.text('Zen Focus'), findsOneWidget);
    });

    testWidgets('WorkspaceViewHost dynamically switches between VibeCodingWorkspaceView and IdeWorkspaceView', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            extensionRuntimeProvider.overrideWithValue(runtime),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1200,
                height: 800,
                child: WorkspaceViewHost(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial mode is IDE
      expect(find.byType(IdeWorkspaceView), findsOneWidget);
      expect(find.byType(VibeCodingWorkspaceView), findsNothing);

      // Switch to Vibe mode
      runtime.workspaceModeController.setMode(CoreWorkspaceModes.vibe);
      await tester.pumpAndSettle();

      expect(find.byType(VibeCodingWorkspaceView), findsOneWidget);
      expect(find.byType(IdeWorkspaceView), findsNothing);
      expect(find.text('VIBE AGENT STREAM'), findsOneWidget);
      expect(find.text('/plan'), findsOneWidget);
    });
  });
}
