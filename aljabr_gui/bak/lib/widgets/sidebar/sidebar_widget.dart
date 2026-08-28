import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_providers.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_colors.dart';
import 'project_switcher.dart';
import 'session_tile.dart';
import 'connection_indicator.dart';

/// Left rail: project switcher, new-session button, history/scheduled
/// shortcuts, pinned sessions, then a collapsible session tree per project.
class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedSessionsProvider);
    final projects = ref.watch(projectListProvider);

    void openSession(String id) {
      ref.read(sessionListProvider.notifier).select(id);
      ref.read(activeSessionIdProvider.notifier).select(id);
    }

    return Container(
      width: 272,
      color: AppTheme.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const ProjectSwitcher(),
          const SizedBox(height: 10),
          _NewSessionButton(),
          const SizedBox(height: 8),
          const _SidebarNavItem(
            icon: Icons.history,
            label: 'Conversation History',
          ),
          const _SidebarNavItem(icon: Icons.schedule, label: 'Scheduled Tasks'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const _SectionLabel('Pinned Sessions'),
                for (final s in pinned)
                  SessionTile(session: s, onTap: () => openSession(s.id)),
                const SizedBox(height: 12),
                const _SectionLabel('Projects'),
                for (final p in projects)
                  _ProjectGroup(projectId: p.id, name: p.name),
              ],
            ),
          ),
          const Divider(height: 1),
          const ConnectionIndicator(),
          const _SidebarNavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Collapsible group of sessions belonging to one project, shown under
/// the "Projects" section (e.g. the wayang-platform tree in the reference).
class _ProjectGroup extends ConsumerStatefulWidget {
  final String projectId;
  final String name;
  const _ProjectGroup({required this.projectId, required this.name});

  @override
  ConsumerState<_ProjectGroup> createState() => _ProjectGroupState();
}

class _ProjectGroupState extends ConsumerState<_ProjectGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsByProjectProvider(widget.projectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(6),
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
                const Icon(
                  Icons.folder_outlined,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sessions.length}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
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
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NewSessionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 18, color: AppTheme.textPrimary),
        label: const Text(
          'New Conversation',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          side: const BorderSide(color: AppTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SidebarNavItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
