import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/security.dart';
import '../providers/project_settings_provider.dart';
import 'radio_option.dart';
import 'section_widget.dart';

class OutsideFoldersSection extends ConsumerWidget {
  const OutsideFoldersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Outside of Folders File Access Policy',
      subtitle:
          'Configures how the agent tries to access files outside of its working folders.',
      child: Column(
        children: [
          RadioOption(
            value: FileAccessPolicy.alwaysAsk,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Always Ask',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          RadioOption(
            value: FileAccessPolicy.allowAll,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Allow All',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          RadioOption(
            value: FileAccessPolicy.denyAll,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Deny All',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          RadioOption(
            value: FileAccessPolicy.allowList,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Allow List',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
        ],
      ),
    );
  }
}
