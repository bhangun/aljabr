import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';

class _TestPlugin implements AljabrPlugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: 'test.plugin',
        name: 'Test Plugin',
        version: '1.0.0',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.views.register(
      ViewContribution(
        id: 'test.view',
        ownerId: metadata.id,
        title: 'Test View',
        preferredPlacement: ViewPlacement.sidebar,
        builder: (_) => const SizedBox(),
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'test.activity',
        ownerId: metadata.id,
        label: 'Test Activity',
        icon: Icons.star,
        defaultViewId: 'test.view',
      ),
    );

    context.context.register(
      ContextContribution(
        id: 'test.context',
        ownerId: metadata.id,
        contribute: (writer) {
          writer.set(CoreContextKeys.workspaceName, 'Plugin Runtime Workspace');
        },
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}

void main() {
  group('PluginManager and Runtime Tests', () {
    late PluginManager manager;

    setUp(() {
      manager = PluginManager();
    });

    test('PluginManager activates, registers UI contributions and context snapshot, and deactivates cleanly', () async {
      final plugin = _TestPlugin();
      await manager.activate(plugin);

      expect(manager.runtime.views.get('test.view'), isNotNull);
      expect(manager.runtime.activityBar.get('test.activity'), isNotNull);

      // Context test
      final snapshot = manager.runtime.contextService.snapshot();
      expect(snapshot.get(CoreContextKeys.workspaceName), 'Plugin Runtime Workspace');

      // Workbench layout interaction
      manager.runtime.workbench.activateActivity('test.activity', defaultViewId: 'test.view');
      expect(manager.runtime.workbench.activeActivityId, 'test.activity');
      expect(manager.runtime.workbench.layout.activeViewIn(ViewArea.sidebar), 'test.view');

      // Deactivation
      await manager.deactivate('test.plugin');
      expect(manager.runtime.views.get('test.view'), isNull);
      expect(manager.runtime.activityBar.get('test.activity'), isNull);
      expect(manager.runtime.workbench.layout.locationOf('test.view'), isNull);
    });
  });
}
