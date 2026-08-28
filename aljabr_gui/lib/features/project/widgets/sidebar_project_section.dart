import 'package:aljabr/features/project/widgets/session_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../providers/active_project_provider.dart';
import '../providers/active_session_provider.dart';
import '../providers/project_list_provider.dart';
import '../providers/session_list_provider.dart';
import '../providers/session_providers.dart';
import 'project_group.dart';

class SidebarProjectSection extends ConsumerWidget {
  const SidebarProjectSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedSessionsProvider);
    final projects = ref.watch(projectListProvider);
    final activeProjectId = ref.watch(activeProjectIdProvider);
    final activeSessionId = ref.watch(activeSessionIdProvider);
    final isGeneralMode = activeProjectId == null || activeProjectId.isEmpty;

    void openSession(String id) {
      ref.read(sessionListProvider.notifier).select(id);
      ref.read(activeSessionIdProvider.notifier).select(id);
    }

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          if (pinned.isNotEmpty) ...[
            const _SectionLabel('Pinned Sessions'),
            for (final s in pinned)
              SessionTile(session: s, onTap: () => openSession(s.id)),
            const SizedBox(height: 12),
          ],

          // General Chat option
          const _SectionLabel('Chat Mode'),
          _GeneralChatTile(
            isSelected: isGeneralMode || activeSessionId == kGeneralSessionId,
            onTap: () {
              ref.read(activeProjectIdProvider.notifier).setId(null);
              ref
                  .read(activeSessionIdProvider.notifier)
                  .select(kGeneralSessionId);
            },
          ),
          const SizedBox(height: 12),

          const _SectionLabel('Projects'),
          for (final p in projects) ProjectGroup(projectId: p.id, name: p.name),
        ],
      ),
    );
  }
}

class _GeneralChatTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _GeneralChatTile({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.sidebarSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : AppTheme.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'General Chat (No Project)',
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chat_bubble_outline,
                  size: 13, color: AppTheme.textMuted),
            ],
          ),
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
