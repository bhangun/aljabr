import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'widgets/agent_run_panel.dart';

class AgentRunPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.agent_run';
  static const viewId = 'aljabr.agent_run.panel';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Agent Execution Monitor',
        version: '1.0.0',
        description: 'Real-time timeline, step details, and execution control for agent runs',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.views.register(
      ViewContribution(
        id: viewId,
        ownerId: pluginId,
        title: 'Agent Run',
        icon: Icons.play_circle_outline,
        preferredPlacement: ViewPlacement.bottomPanel,
        behavior: ViewBehavior.panel,
        builder: (_) => const AgentRunPanel(),
      ),
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.agent_run.open',
        title: 'Agent Run: Show Active Execution Panel',
        category: 'Agent',
        icon: Icons.play_circle_outline,
        action: (cmdCtx) {},
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
