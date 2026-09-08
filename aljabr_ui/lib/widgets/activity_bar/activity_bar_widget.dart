import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import '../workbench/views/vscode_sidebar_view.dart';
import '../../providers/module_manager_provider.dart';
import '../../theme/app_colors.dart';

class ActiveActivityBarItemNotifier extends Notifier<String?> {
  @override
  String? build() => 'aljabr.activity.projects';

  void select(String? id) => state = id;
}

final activeActivityBarItemProvider =
    NotifierProvider<ActiveActivityBarItemNotifier, String?>(
  () => ActiveActivityBarItemNotifier(),
);

class ActivityBarWidget extends ConsumerWidget {
  const ActivityBarWidget({super.key});

  void _handleItemTap(
    BuildContext context,
    WidgetRef ref,
    ActivityBarContribution item,
    WorkbenchController workbench,
  ) {
    final activeItem = ref.read(activeActivityBarItemProvider);
    final isCurrent = item.id == activeItem;

    if (isCurrent && workbench.layout.pane(PaneId.sidebar).visible) {
      workbench.hidePane(PaneId.sidebar);
    } else {
      workbench.showPane(PaneId.sidebar);
      ref.read(activeActivityBarItemProvider.notifier).select(item.id);

      switch (item.id) {
        case 'aljabr.activity.projects':
          ref
              .read(vsCodeSidebarTabProvider.notifier)
              .select(VsCodeSidebarTab.projects);
          break;
        case 'aljabr.activity.explorer':
          ref
              .read(vsCodeSidebarTabProvider.notifier)
              .select(VsCodeSidebarTab.explorer);
          break;
        case 'aljabr.activity.search':
          ref
              .read(vsCodeSidebarTabProvider.notifier)
              .select(VsCodeSidebarTab.search);
          break;
        case 'aljabr.activity.source_control':
        case 'aljabr.activity.git':
          ref
              .read(vsCodeSidebarTabProvider.notifier)
              .select(VsCodeSidebarTab.sourceControl);
          break;
        case 'aljabr.activity.extensions':
        case 'aljabr.activity.plugins':
          ref
              .read(vsCodeSidebarTabProvider.notifier)
              .select(VsCodeSidebarTab.extensions);
          break;
        case 'aljabr.activity.chat':
        case 'aljabr.activity.assistant':
          ref
              .read(vsCodeSidebarTabProvider.notifier)
              .select(VsCodeSidebarTab.assistant);
          break;
      }
    }

    if (item.defaultViewId != null) {
      workbench.activateActivity(
        item.id,
        defaultViewId: item.defaultViewId,
      );
    }
    if (item.action != null) {
      item.action!(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(activityBarRegistryProvider);
    final workbench = ref.watch(workbenchControllerProvider);
    final activeItem = ref.watch(activeActivityBarItemProvider);

    final primaryItems = registry.primaryItems;
    final secondaryItems = registry.secondaryItems;
    final bottomItems = registry.bottomItems;

    return Container(
      width: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(right: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (final item in primaryItems)
            _ActivityBarIcon(
              item: item,
              isSelected: item.id == activeItem,
              onTap: () => _handleItemTap(context, ref, item, workbench),
            ),
          if (primaryItems.isNotEmpty && secondaryItems.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Divider(color: AppTheme.border, height: 1),
            ),
          for (final item in secondaryItems)
            _ActivityBarIcon(
              item: item,
              isSelected: item.id == activeItem,
              onTap: () => _handleItemTap(context, ref, item, workbench),
            ),
          const Spacer(),
          if (bottomItems.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Divider(color: AppTheme.border, height: 1),
            ),
          for (final item in bottomItems)
            _ActivityBarIcon(
              item: item,
              isSelected: item.id == activeItem,
              onTap: () => _handleItemTap(context, ref, item, workbench),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActivityBarIcon extends StatelessWidget {
  final ActivityBarContribution item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityBarIcon({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      preferBelow: false,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (isSelected)
            Container(
              width: 2.5,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                  ),
                  splashRadius: 18,
                  onPressed: onTap,
                ),
                if (item.badgeBuilder != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: item.badgeBuilder!(context, isSelected ? item.id : null) ??
                        const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
