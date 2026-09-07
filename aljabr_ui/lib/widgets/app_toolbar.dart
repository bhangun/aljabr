import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../providers/module_manager_provider.dart';
import '../theme/app_colors.dart';
import 'workbench/modes/workspace_mode_segmented_switch.dart';


class AppToolbar extends ConsumerWidget {
  final String targetId;
  final ToolbarContext? contextData;

  const AppToolbar({
    super.key,
    this.targetId = ToolbarTargets.app,
    this.contextData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = contextData ?? ToolbarContext(targetId: targetId);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppTheme.panel,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        children: [
          _ToolbarSlot(
            targetId: targetId,
            alignment: ToolbarAlignment.start,
            toolbarContext: ctx,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WorkspaceModeSegmentedSwitch(),
              const SizedBox(width: 8),
              _ToolbarSlot(
                targetId: targetId,
                alignment: ToolbarAlignment.center,
                toolbarContext: ctx,
              ),
            ],
          ),
          const Spacer(),

          _ToolbarSlot(
            targetId: targetId,
            alignment: ToolbarAlignment.end,
            toolbarContext: ctx,
          ),
        ],
      ),
    );
  }
}

class _ToolbarSlot extends ConsumerWidget {
  final String targetId;
  final ToolbarAlignment alignment;
  final ToolbarContext toolbarContext;

  const _ToolbarSlot({
    required this.targetId,
    required this.alignment,
    required this.toolbarContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(toolbarRegistryProvider);
    final items = registry.resolve(toolbarContext, alignment);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items) ...[
          _ToolbarItem(item: item, toolbarContext: toolbarContext),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _ToolbarItem extends ConsumerWidget {
  final ToolbarContribution item;
  final ToolbarContext toolbarContext;

  const _ToolbarItem({
    required this.item,
    required this.toolbarContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (item.kind) {
      case ToolbarItemKind.command:
        return _CommandToolbarButton(item: item);

      case ToolbarItemKind.action:
        return IconButton(
          tooltip: item.tooltip,
          icon: Icon(item.icon, size: 16, color: AppTheme.textSecondary),
          splashRadius: 16,
          onPressed: item.isEnabled?.call(toolbarContext) == false
              ? null
              : () async {
                  await item.action?.call(context);
                },
        );

      case ToolbarItemKind.widget:
        return item.builder != null
            ? item.builder!(context)
            : const SizedBox.shrink();

      case ToolbarItemKind.menu:
        return IconButton(
          tooltip: item.tooltip,
          icon: Icon(item.icon ?? Icons.more_vert, size: 16, color: AppTheme.textSecondary),
          splashRadius: 16,
          onPressed: () {},
        );
    }
  }
}

class _CommandToolbarButton extends ConsumerWidget {
  final ToolbarContribution item;

  const _CommandToolbarButton({
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.commandId == null) return const SizedBox.shrink();
    final command = ref.read(commandRegistryProvider).get(item.commandId!);

    if (command == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: item.tooltip ?? command.title,
      icon: Icon(item.icon ?? command.icon, size: 16, color: AppTheme.textSecondary),
      splashRadius: 16,
      onPressed: () {
        command.action?.call(CommandContext(context: context));
      },
    );
  }
}
