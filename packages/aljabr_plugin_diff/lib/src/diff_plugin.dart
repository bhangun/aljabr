import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'widgets/diff_panel.dart';

class DiffPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.diff';
  static const viewId = 'aljabr.diff.panel';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Diff & Review',
        version: '1.0.0',
        description: 'Interactive code diff viewer, hunk review, and change inspection',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.views.register(
      ViewContribution(
        id: viewId,
        ownerId: pluginId,
        title: 'Diff',
        icon: Icons.difference_outlined,
        preferredPlacement: ViewPlacement.bottomPanel,
        behavior: ViewBehavior.panel,
        builder: (_) => const DiffPanel(),
      ),
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.diff.open',
        title: 'Diff: Show Changes & Review Hunks',
        category: 'Diff',
        icon: Icons.difference_outlined,
        action: (cmdCtx) {},
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
