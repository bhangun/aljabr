import 'package:flutter_riverpod/legacy.dart';

import '../models/project_detail.dart';
import '../models/rule_item.dart';
import '../models/skill_detail.dart';
import '../models/skill_item.dart';

final projectDetailsProvider =
    StateNotifierProvider<ProjectDetailsNotifier, ProjectDetails>((ref) {
  return ProjectDetailsNotifier();
});

class ProjectDetailsNotifier extends StateNotifier<ProjectDetails> {
  ProjectDetailsNotifier()
      : super(
          const ProjectDetails(
            projectName: 'wayang-platform',
            rules: [
              SkillItem(
                id: 'rule-1',
                name: 'Rules',
                percentage: 0.1,
                count: 13,
                isExpanded: false,
                type: SkillType.rule,
                items: [
                  RuleItem(
                    id: 'rule-1-1',
                    name: 'Show 1 breakdown',
                    isBreakdown: true,
                  ),
                ],
              ),
            ],
            skills: [
              SkillItem(
                id: 'skill-1',
                name: 'Skills',
                percentage: 4.6,
                count: 925,
                isExpanded: false,
                type: SkillType.skill,
                items: [],
              ),
            ],
            skillDetails: [
              SkillDetail(
                id: 'skill-1',
                name: 'android-cli',
                type: 'Global',
                plugin: 'Plugin: android-cli-plugin',
                description:
                    'Orchestrates Android development tasks including project creation, deployment, SDK management, and environment diagnostics using the \'android\' command-line tool.',
              ),
              SkillDetail(
                id: 'skill-2',
                name: 'antigravity-guide',
                type: 'Global',
                plugin: '',
                description:
                    'Provides a comprehensive guide, quick reference, and sitemap for Google Antigravity (AGY), including the Antigravity CLI (agy), Antigravity 2.0, Antigravity IDE, Python SDK, slash commands,',
              ),
              SkillDetail(
                id: 'skill-3',
                name: 'chrome-extensions',
                type: 'Global',
                plugin: 'Plugin: modern-web-guidance-plugin',
                description:
                    'Build and publish Chrome Extensions using Manifest V3 best practices. Use the skill whenever the user asks to create, modify, debug, or understand Chrome browser extensions, add-ons, or...',
              ),
              SkillDetail(
                id: 'skill-4',
                name: 'modern-web-guidance',
                type: 'Global',
                plugin: 'Plugin: modern-web-guidance-plugin',
                description:
                    'Search tool for modern web development best practices. MANDATORY: Execute FIRST for all HTML/CSS and client side JS tasks. Do NOT skip - web APIs evolve rapidly and training weights...',
              ),
            ],
            rulesList: [
              RuleItem(
                id: 'rule-2-1',
                name: 'user_global',
                isBreakdown: false,
                description: 'just run the script without permission',
              ),
            ],
            activeConversations: 27,
            archivedConversations: 0,
          ),
        );

  void toggleSkillExpansion(String id) {
    final updatedSkills = state.skills.map((skill) {
      if (skill.id == id) {
        return skill.copyWith(isExpanded: !skill.isExpanded);
      }
      return skill;
    }).toList();
    state = state.copyWith(skills: updatedSkills);
  }

  void toggleRuleExpansion(String id) {
    final updatedRules = state.rules.map((rule) {
      if (rule.id == id) {
        return rule.copyWith(isExpanded: !rule.isExpanded);
      }
      return rule;
    }).toList();
    state = state.copyWith(rules: updatedRules);
  }
}
