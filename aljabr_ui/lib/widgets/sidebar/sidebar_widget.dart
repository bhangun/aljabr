import 'package:aljabr/features/project/widgets/sidebar_project_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../providers/module_manager_provider.dart';

import '../../features/project/widgets/new_project_button.dart';
import '../../features/project/widgets/new_session_button.dart';
import '../../theme/app_colors.dart';
import '../../features/project/widgets/project_switcher.dart';
import 'connection_indicator.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(navigationRegistryProvider);
    final groups = registry.groups;

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
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              children: [
                for (final group in groups)
                  _NavigationGroupSection(
                    group: group,
                    items: registry.itemsForGroup(group.id),
                  ),
                const SidebarProjectSection(),
              ],
            ),
          ),
          
          const Divider(height: 1),
          const ConnectionIndicator(),
        ],
      ),
    );
  }
}

class _NavigationGroupSection extends ConsumerWidget {
  final NavigationGroup group;
  final List<NavigationContribution> items;

  const _NavigationGroupSection({
    required this.group,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            group.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        for (final item in items) _NavigationItem(item: item),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _NavigationItem extends ConsumerWidget {
  final NavigationContribution item;

  const _NavigationItem({required this.item});

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
            Icon(item.icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Text(item.label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
