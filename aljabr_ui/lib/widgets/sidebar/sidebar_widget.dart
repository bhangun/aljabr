import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../providers/module_manager_provider.dart';

import '../../features/project/widgets/new_project_button.dart';
import '../../features/project/widgets/new_session_button.dart';
import '../../features/project/widgets/project_switcher.dart';
import '../../features/project/widgets/sidebar_project_section.dart';
import '../../theme/app_colors.dart';
import 'connection_indicator.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(navigationRegistryProvider);
    
    // Top groups are anything other than 'management'
    final topGroups = registry.groups
        .where((g) => g.id != BuiltInNavigationGroups.management.id)
        .toList();

    // Management / footer items
    final managementItems =
        registry.itemsForGroup(BuiltInNavigationGroups.management.id);

    return Container(
      width: 272,
      color: AppTheme.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const ProjectSwitcher(),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(child: NewProjectButton()),
                SizedBox(width: 8),
                Expanded(child: NewSessionButton()),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Top Navigation Items (e.g. Conversation History, Scheduled Tasks, Agent)
          for (final group in topGroups)
            for (final item in registry.itemsForGroup(group.id))
              _NavigationItem(key: ValueKey(item.id), item: item),

          const SizedBox(height: 8),

          // Middle scrollable project & session tree (takes remaining space)
          const SidebarProjectSection(),

          // Bottom Footer
          const Divider(height: 1),
          const ConnectionIndicator(),

          // Management Contributions (Infrastructure, Compliance, Metrics, Settings)
          for (final item in managementItems)
            _NavigationItem(key: ValueKey(item.id), item: item),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavigationItem extends ConsumerWidget {
  final NavigationContribution item;

  const _NavigationItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        if (item.action != null) {
          await item.action!(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
