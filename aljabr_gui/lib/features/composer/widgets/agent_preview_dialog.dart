import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/composer_provider.dart';

class AgentPermissions {
  final bool readFiles;
  final bool writeFiles;
  final bool runCommands;
  final bool runTests;
  final bool network;

  const AgentPermissions(
      {this.readFiles = true,
      this.writeFiles = false,
      this.runCommands = true,
      this.runTests = true,
      this.network = false});
}

class AgentPreviewDialog extends ConsumerStatefulWidget {
  const AgentPreviewDialog({super.key});

  @override
  ConsumerState<AgentPreviewDialog> createState() => _AgentPreviewDialogState();
}

class _AgentPreviewDialogState extends ConsumerState<AgentPreviewDialog> {
  AgentPermissions perms = const AgentPermissions();

  @override
  Widget build(BuildContext context) {
    final ctxs = ref.watch(composerProvider).contexts;
    return AlertDialog(
      title: const Text('Agent run preview'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Planned steps:'),
            const SizedBox(height: 8),
            const Text(
                '1. Inspect relevant files\n2. Apply minimal patches\n3. Run tests\n4. Present diff and verification'),
            const SizedBox(height: 12),
            const Text('Scope:'),
            for (final c in ctxs)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('- ${c.displayLabel}')),
            const SizedBox(height: 12),
            const Text('Permissions'),
            SwitchListTile(
                title: const Text('Read files'),
                value: perms.readFiles,
                onChanged: (v) => setState(() => perms = AgentPermissions(
                    readFiles: v,
                    writeFiles: perms.writeFiles,
                    runCommands: perms.runCommands,
                    runTests: perms.runTests,
                    network: perms.network))),
            SwitchListTile(
                title: const Text('Modify files'),
                value: perms.writeFiles,
                onChanged: (v) => setState(() => perms = AgentPermissions(
                    readFiles: perms.readFiles,
                    writeFiles: v,
                    runCommands: perms.runCommands,
                    runTests: perms.runTests,
                    network: perms.network))),
            SwitchListTile(
                title: const Text('Run tests'),
                value: perms.runTests,
                onChanged: (v) => setState(() => perms = AgentPermissions(
                    readFiles: perms.readFiles,
                    writeFiles: perms.writeFiles,
                    runCommands: perms.runCommands,
                    runTests: v,
                    network: perms.network))),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            // Start a simulated agent run: append a plan entry to chat and close
            ref
                .read(composerProvider.notifier)
                .startAgentRun('Apply planned changes', perms);
            Navigator.of(context).pop();
          },
          child: const Text('Start agent'),
        ),
      ],
    );
  }
}
