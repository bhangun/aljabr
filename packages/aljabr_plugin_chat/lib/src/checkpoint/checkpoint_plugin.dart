import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

class CheckpointPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.checkpoint';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Workspace Checkpoints',
        version: '1.0.0',
        description: 'Session snapshots and checkpoint rollback management',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.commands.register(
      AppCommand(
        id: 'aljabr.checkpoint.create',
        title: 'Checkpoint: Create Session Snapshot',
        category: 'Checkpoint',
        icon: Icons.bookmark_add_outlined,
        action: (cmdCtx) {},
      ),
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.checkpoint.restore',
        title: 'Checkpoint: Restore Snapshot',
        category: 'Checkpoint',
        icon: Icons.restore,
        action: (cmdCtx) {},
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
