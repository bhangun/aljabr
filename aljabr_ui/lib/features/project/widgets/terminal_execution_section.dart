import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/security.dart';
import '../providers/project_settings_provider.dart';
import 'radio_option.dart';
import 'section_widget.dart';

class TerminalExecutionSection extends ConsumerWidget {
  const TerminalExecutionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Terminal Command Auto Execution',
      subtitle:
          'Controls whether terminal commands require your approval before running.',
      child: Column(
        children: [
          RadioOption(
            value: TerminalExecutionPolicy.requireReview,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Require Review',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
          RadioOption(
            value: TerminalExecutionPolicy.autoApprove,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
          RadioOption(
            value: TerminalExecutionPolicy.autoDeny,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
        ],
      ),
    );
  }
}
