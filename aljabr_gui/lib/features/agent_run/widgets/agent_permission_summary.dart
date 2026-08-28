import 'package:flutter/material.dart';

class AgentPermissions {
  final bool readFiles;
  final bool writeFiles;
  final bool runTests;
  final bool runCommands;
  final bool network;

  const AgentPermissions(
      {this.readFiles = true,
      this.writeFiles = true,
      this.runTests = true,
      this.runCommands = true,
      this.network = false});
}

class AgentPermissionSummary extends StatelessWidget {
  const AgentPermissionSummary({super.key, required this.permissions});
  final AgentPermissions permissions;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, bool enabled) => Chip(
        label: Text(label),
        backgroundColor: enabled
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.08));

    return Wrap(spacing: 8, runSpacing: 6, children: [
      chip('Read files', permissions.readFiles),
      chip('Modify files', permissions.writeFiles),
      chip('Run tests', permissions.runTests),
      chip('Commands', permissions.runCommands),
      chip('Network', permissions.network),
    ]);
  }
}
