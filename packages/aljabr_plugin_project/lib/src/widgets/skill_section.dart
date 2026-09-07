import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'skill_detail_tile.dart';
import 'skill_header.dart';

class SkillsSection extends ConsumerWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(projectDetailsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...details.skills.map(
          (skill) => SkillHeader(
            skill: skill,
            onTap: () {
              ref
                  .read(projectDetailsProvider.notifier)
                  .toggleSkillExpansion(skill.id);
            },
          ),
        ),
        if (details.skills.any((s) => s.isExpanded))
          ...details.skillDetails.map(
            (detail) => SkillDetailTile(detail: detail),
          ),
      ],
    );
  }
}
