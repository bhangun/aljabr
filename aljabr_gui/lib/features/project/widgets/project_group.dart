import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../providers/active_project_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/project_list_provider.dart';
import '../providers/session_list_provider.dart';
import '../providers/session_providers.dart';
import 'session_tile.dart';

/// Collapsible group of sessions belonging to one project, shown under
/// the "Projects" section.
class ProjectGroup extends ConsumerStatefulWidget {
  final String projectId;
  final String name;
  const ProjectGroup({super.key, required this.projectId, required this.name});

  @override
  ConsumerState<ProjectGroup> createState() => ProjectGroupState();
}

class ProjectGroupState extends ConsumerState<ProjectGroup> {
  bool _expanded = true;

  void _confirmDeleteProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Delete Project',
            style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${widget.name}"? All sessions will be removed locally.',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(projectListProvider.notifier)
                  .deleteProject(widget.projectId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsByProjectProvider(widget.projectId));
    final activeProjectId = ref.watch(activeProjectIdProvider);
    final isActive = activeProjectId == widget.projectId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // Select project on click
            ref.read(activeProjectIdProvider.notifier).setId(widget.projectId);
            setState(() => _expanded = !_expanded);
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.sidebarSelected.withValues(alpha: 0.4)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    size: 15,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.folder_outlined,
                    size: 14,
                    color: isActive
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 12.5,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('${sessions.length}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(width: 6),
                  // Add session button
                  GestureDetector(
                    onTap: () async {
                      final title =
                          'Session ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                      final notifier = ref.read(sessionListProvider.notifier);
                      await notifier.createSession(widget.projectId, title);

                      if (!_expanded) {
                        setState(() => _expanded = true);
                      }

                      final allSessions = ref.read(sessionListProvider);
                      if (allSessions.isNotEmpty) {
                        final newSession = allSessions.last;
                        ref
                            .read(activeSessionIdProvider.notifier)
                            .select(newSession.id);
                        ref
                            .read(activeProjectIdProvider.notifier)
                            .setId(widget.projectId);
                      }
                    },
                    child: const Tooltip(
                      message: 'New Session',
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.add,
                            size: 15, color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Delete project button
                  GestureDetector(
                    onTap: () => _confirmDeleteProject(context),
                    child: const Tooltip(
                      message: 'Delete Project',
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.delete_outline,
                            size: 14, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                for (final s in sessions)
                  SessionTile(
                    session: s,
                    onTap: () {
                      ref.read(sessionListProvider.notifier).select(s.id);
                      ref.read(activeSessionIdProvider.notifier).select(s.id);
                      ref
                          .read(activeProjectIdProvider.notifier)
                          .setId(widget.projectId);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
