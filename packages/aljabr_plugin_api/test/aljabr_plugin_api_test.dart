import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

class _SamplePlugin implements AljabrPlugin {
  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: 'sample.plugin',
        name: 'Sample Plugin',
        version: '1.0.0',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.commands.register(
      AppCommand(
        id: 'sample.hello',
        title: 'Sample: Hello',
        action: (_) {},
      ),
    );

    context.ui.views.register(
      ViewContribution(
        id: 'sample.view',
        ownerId: metadata.id,
        title: 'Sample View',
        preferredPlacement: ViewPlacement.sidebar,
        builder: (_) => const SizedBox(),
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'sample.activity',
        ownerId: metadata.id,
        label: 'Sample',
        icon: Icons.extension,
        defaultViewId: 'sample.view',
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}

void main() {
  test('AljabrPlugin contracts and metadata can be instantiated', () {
    final plugin = _SamplePlugin();
    expect(plugin.metadata.id, 'sample.plugin');
    expect(plugin.metadata.name, 'Sample Plugin');
    expect(plugin.metadata.version, '1.0.0');
  });

  test('ContextKey and ContextSnapshot store and retrieve typed values', () {
    final builder = ContextBuilder();
    builder.set(CoreContextKeys.workspaceName, 'Wayang Platform');
    builder.set(CoreContextKeys.gitBranch, 'main');

    final snapshot = builder.build();
    expect(snapshot.get(CoreContextKeys.workspaceName), 'Wayang Platform');
    expect(snapshot.get(CoreContextKeys.gitBranch), 'main');
    expect(snapshot.get(CoreContextKeys.filePath), isNull);
  });
}
