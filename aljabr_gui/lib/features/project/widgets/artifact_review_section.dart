import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/security.dart';
import '../providers/project_settings_provider.dart';
import 'radio_option.dart';
import 'section_widget.dart';

class ArtifactReviewSection extends ConsumerWidget {
  const ArtifactReviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Artifact Review Policy',
      subtitle:
          "Specifies Agent's behavior when asking for review on artifacts, which are documents it creates to enable a richer conversation experience.",
      child: Column(
        children: [
          RadioOption(
            value: ArtifactReviewPolicy.alwaysAsk,
            groupValue: settings.artifactReviewPolicy,
            label: 'Always Ask',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
          RadioOption(
            value: ArtifactReviewPolicy.autoApprove,
            groupValue: settings.artifactReviewPolicy,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
          RadioOption(
            value: ArtifactReviewPolicy.autoDeny,
            groupValue: settings.artifactReviewPolicy,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
        ],
      ),
    );
  }
}
