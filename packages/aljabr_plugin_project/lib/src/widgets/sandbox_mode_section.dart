import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'section_widget.dart';

class SandboxModeSection extends ConsumerWidget {
  const SandboxModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Enable Sandbox Mode (Preview)',
      subtitle: 'Restricts agent tools to a secure, isolated local sandbox.',
      child: SwitchListTile(
        value: settings.enableSandboxMode,
        onChanged: (value) {
          ref.read(projectSettingsProvider.notifier).updateSandboxMode(value);
        },
        title: const Text('Enable Sandbox Mode'),
        subtitle: const Text('Preview feature - may have limitations'),
        activeThumbColor: Colors.blue,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}
