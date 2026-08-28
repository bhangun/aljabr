import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/security.dart';
import '../providers/project_settings_provider.dart';
import 'radio_option.dart';
import 'section_widget.dart';

class SecurityPresetSection extends ConsumerWidget {
  const SecurityPresetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Security Preset',
      subtitle:
          'Choose a predefined security preset for the agent. This controls terminal auto-execution policy, and file access policy.',
      child: Column(
        children: [
          RadioOption(
            value: SecurityPreset.custom,
            groupValue: settings.securityPreset,
            label: 'Custom',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
          RadioOption(
            value: SecurityPreset.standard,
            groupValue: settings.securityPreset,
            label: 'Standard',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
          RadioOption(
            value: SecurityPreset.strict,
            groupValue: settings.securityPreset,
            label: 'Strict',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
        ],
      ),
    );
  }
}
