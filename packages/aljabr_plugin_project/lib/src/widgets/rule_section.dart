import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'rule_tile.dart';
import 'skill_header.dart';

class RulesSection extends ConsumerWidget {
  const RulesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(projectDetailsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rules',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...details.rules.map(
          (rule) => SkillHeader(
            skill: rule,
            onTap: () {
              ref
                  .read(projectDetailsProvider.notifier)
                  .toggleRuleExpansion(rule.id);
            },
          ),
        ),
        if (details.rules.any((r) => r.isExpanded))
          ...details.rulesList.map((rule) => RuleTile(rule: rule)),
      ],
    );
  }
}
