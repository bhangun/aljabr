import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'widgets/mutation_panel.dart';

class MutationsPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.mutations';
  static const viewId = 'aljabr.mutations.panel';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr File Mutation Records',
        version: '1.0.0',
        description: 'Track, view, and inspect atomic code mutations recorded by agent tasks',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.views.register(
      ViewContribution(
        id: viewId,
        ownerId: pluginId,
        title: 'Mutations',
        icon: Icons.history_edu_outlined,
        preferredPlacement: ViewPlacement.bottomPanel,
        behavior: ViewBehavior.panel,
        builder: (_) => const MutationPanel(),
      ),
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.mutations.open',
        title: 'Mutations: Open Mutation History Panel',
        category: 'Mutations',
        icon: Icons.history_edu_outlined,
        action: (cmdCtx) {},
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
