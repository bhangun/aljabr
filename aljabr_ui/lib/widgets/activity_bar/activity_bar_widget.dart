import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../providers/module_manager_provider.dart';
import '../../theme/app_colors.dart';

final activeActivityBarItemProvider = StateProvider<String?>((ref) => 'aljabr.activity.explorer');

class ActivityBarWidget extends ConsumerWidget {
  const ActivityBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(activityBarRegistryProvider);
    final topItems = registry.topItems;
    final bottomItems = registry.bottomItems;
    final activeItem = ref.watch(activeActivityBarItemProvider);

    return Container(
      width: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(right: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (final item in topItems)
            _ActivityBarIcon(
              item: item,
              isSelected: item.id == activeItem,
              onTap: () {
                ref.read(activeActivityBarItemProvider.notifier).state = item.id;
                if (item.action != null) {
                  item.action!(context);
                }
              },
            ),
          const Spacer(),
          for (final item in bottomItems)
            _ActivityBarIcon(
              item: item,
              isSelected: item.id == activeItem,
              onTap: () {
                ref.read(activeActivityBarItemProvider.notifier).state = item.id;
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
      message: item.title,
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
            child: IconButton(
              icon: Icon(
                item.icon,
                size: 20,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
              splashRadius: 18,
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
