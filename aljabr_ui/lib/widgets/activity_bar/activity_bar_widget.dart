import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../providers/module_manager_provider.dart';
import '../../theme/app_colors.dart';

class ActiveActivityBarItemNotifier extends Notifier<String?> {
  @override
  String? build() => 'aljabr.activity.explorer';

  void select(String? id) => state = id;
}

final activeActivityBarItemProvider =
    NotifierProvider<ActiveActivityBarItemNotifier, String?>(
  () => ActiveActivityBarItemNotifier(),
);

class ActivityBarWidget extends ConsumerWidget {
  const ActivityBarWidget({super.key});

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
              onTap: () {
                ref
                    .read(activeActivityBarItemProvider.notifier)
                    .select(item.id);
                if (item.defaultViewId != null) {
                  workbench.activateActivity(
                    item.id,
                    defaultViewId: item.defaultViewId,
                  );
                }
                if (item.action != null) {
                  item.action!(context);
                }
              },
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
              onTap: () {
                ref
                    .read(activeActivityBarItemProvider.notifier)
                    .select(item.id);
                if (item.defaultViewId != null) {
                  workbench.activateActivity(
                    item.id,
                    defaultViewId: item.defaultViewId,
                  );
                }
                if (item.action != null) {
                  item.action!(context);
                }
              },
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
              onTap: () {
                ref
                    .read(activeActivityBarItemProvider.notifier)
                    .select(item.id);
                if (item.defaultViewId != null) {
                  workbench.activateActivity(
                    item.id,
                    defaultViewId: item.defaultViewId,
                  );
                }
                if (item.action != null) {
                  item.action!(context);
                }
              },
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
