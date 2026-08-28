import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_providers.dart';
import '../../theme/app_colors.dart';

/// Header dropdown to switch which [Project] the sidebar/session tree
/// is scoped to — mirrors the workspace switcher in Codex/Antigravity.
class ProjectSwitcher extends ConsumerWidget {
  const ProjectSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectListProvider);
    final active = ref.watch(activeProjectProvider);

    return PopupMenuButton<String>(
      color: AppTheme.panelAlt,
      offset: const Offset(0, 36),
      onSelected: (id) => ref.read(activeProjectIdProvider.notifier).select(id),
      itemBuilder: (context) => [
        for (final p in projects)
          PopupMenuItem(
            value: p.id,
            child: Row(
              children: [
                const Icon(
                  Icons.folder,
                  size: 15,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  p.name,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.panelAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder, size: 15, color: AppTheme.accentBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                active.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (active.branch != null) ...[
              const Icon(Icons.call_split, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 3),
              Text(
                active.branch!,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.unfold_more, size: 15, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
