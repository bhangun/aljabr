import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr/core/workbench_platform_config.dart';
import 'package:aljabr_coding_pack/aljabr_coding_pack.dart';
import 'package:aljabr/providers/module_manager_provider.dart';
import 'package:aljabr/widgets/workbench/modes/generic_workbench_layout_view.dart';
import 'package:aljabr/widgets/workbench/modes/vibe_coding_workspace_view.dart';
import 'package:aljabr/widgets/workbench/modes/workspace_view_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Agnostic Workbench Platform & Custom Domain Packs', () {
    late ExtensionRuntime runtime;
    late PluginManager pluginManager;

    setUp(() {
      runtime = ExtensionRuntime();
      pluginManager = PluginManager(runtime: runtime);
    });

    test('WorkbenchPlatformConfig allows custom app branding and defaults', () {
      final config = WorkbenchPlatformConfig(
        appName: 'FlowCraft Automation Studio',
        defaultModeId: 'workflow_builder',
        initialModes: const [
          WorkspaceMode(
            id: 'workflow_builder',
            title: 'Workflow Builder',
            description: 'Visual low-code pipeline canvas',
            icon: Icons.account_tree_outlined,
          ),
        ],
      );

      expect(config.appName, equals('FlowCraft Automation Studio'));
      expect(config.defaultModeId, equals('workflow_builder'));
      expect(config.initialModes.length, equals(1));
      expect(config.initialModes.first.id, equals('workflow_builder'));
    });

    test('CodingAgentPluginPack registers as domain pack with vibe mode and commands', () async {
      final pack = CodingAgentPluginPack();
      await pluginManager.activate(pack);

      // Verify pack is active
      expect(pluginManager.activePlugins.any((p) => p.metadata.id == CodingAgentPluginPack.pluginId), isTrue);

      // Verify vibe mode registered with viewBuilder
      final vibeMode = runtime.workspaceModes.get(CoreWorkspaceModes.vibe);
      expect(vibeMode, isNotNull);
      expect(vibeMode!.viewBuilder, isNotNull);

      // Verify pack commands registered
      expect(runtime.commands.all.any((c) => c.id == 'aljabr.coding.vibeMode'), isTrue);
      expect(runtime.commands.all.any((c) => c.id == 'aljabr.coding.ideMode'), isTrue);
    });

    testWidgets('WorkspaceViewHost dynamically renders custom domain viewBuilder (e.g. Low-Code Canvas)', (tester) async {
      const customModeId = 'low_code_workflow';

      // Register custom domain mode with custom canvas view builder
      runtime.workspaceModes.register(
        WorkspaceMode(
          id: customModeId,
          title: 'Flow Canvas',
          description: 'Interactive low-code node graph',
          icon: Icons.account_tree,
          viewBuilder: (context) => const Center(
            key: Key('custom_workflow_canvas'),
            child: Text('LOW CODE WORKFLOW CANVAS ACTIVE'),
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            extensionRuntimeProvider.overrideWithValue(runtime),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1000,
                height: 700,
                child: WorkspaceViewHost(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on IDE mode: GenericWorkbenchLayoutView is rendered
      expect(find.byType(GenericWorkbenchLayoutView), findsOneWidget);
      expect(find.byKey(const Key('custom_workflow_canvas')), findsNothing);

      // Switch to custom low-code mode
      runtime.workspaceModeController.setMode(customModeId);
      await tester.pumpAndSettle();

      // Custom domain view builder rendered!
      expect(find.byKey(const Key('custom_workflow_canvas')), findsOneWidget);
      expect(find.text('LOW CODE WORKFLOW CANVAS ACTIVE'), findsOneWidget);
      expect(find.byType(GenericWorkbenchLayoutView), findsNothing);
      expect(find.byType(VibeCodingWorkspaceView), findsNothing);
    });

    testWidgets('WorkspaceViewHost renders VibeCodingWorkspaceView in vibe mode', (tester) async {
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

      // Switch to vibe mode
      runtime.workspaceModeController.setMode(CoreWorkspaceModes.vibe);
      await tester.pumpAndSettle();

      expect(find.byType(VibeCodingWorkspaceView), findsOneWidget);
      expect(find.text('VIBE AGENT STREAM'), findsOneWidget);
    });
  });
}
